# Trabalho RA1, Grupo 2
# Alunos: (Deixar em ordem alfabética)
# - Jorge Samuel Teixeira Jordão, JorgeSTJordao
# - Matheus Vinius Mariussi, MatheusVMariussi
# - Pedro Henrique Vargas Navarro, Navarro45
# - Nome do Aluno 4, Nome do github 4

import sys
import re
from testesAnalisadorLexico import testar_analisador_lexico
from testesExecutarExpressao import testar_executar_expressao
from maquinaDeEstados import parseExpressao

# TODO (serão implementados pelos outros membros do grupo)

def lerArquivo(nomeArquivo):
    linhas = []

    with open(nomeArquivo, "r", encoding="utf-8") as arquivo:
        for linha in arquivo:
            linhas.append(linha.strip())

    return linhas


"""
Gerador de código Assembly ARMv7 para expressões RPN.
Compatível com CPUlator ARMv7 DE1-SoC (Cortex-A9, neon-fp16, softfp).
"""
 
import re
 
SEG7_DIGITS = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F]
SEG7_BLANK  = 0x00
SEG7_MINUS  = 0x40
 
 
def gerarAssembly(tokens: list[str]) -> str:
    """
    Converte uma lista de tokens RPN em código Assembly ARMv7.
    O resultado inteiro é exibido nos displays HEX0–HEX5.
    """
 
    if not tokens:
        raise ValueError("Lista de tokens vazia.")
 
    # ------------------------------------------------------------------
    # Estado interno
    # ------------------------------------------------------------------
    code       = []
    data       = []
    stack      = []    # {"reg": str, "kind": "float"|"int"}
    history    = []
    const_pool = {}
    mem_vars   = set()
    label_n    = [0]
    dreg_n     = [0]    # registradores d0-d15 (double, 64 bits)
                        # Registradores inteiros r0-r10 reservados para a expressão.
                        # r11-r12 reservados para a rotina de display (não colidem).
    ireg_n     = [0]
 
    # ------------------------------------------------------------------
    # Utilitários básicos
    # ------------------------------------------------------------------
 
    def new_label(prefix="L"):
        lbl = f"{prefix}{label_n[0]}"
        label_n[0] += 1
        return lbl
 
    def dreg():
        if dreg_n[0] > 13:   # deixa d14/d15 para scratches internos
            raise RuntimeError("Registradores VFP esgotados (máx d13).")
        r = f"d{dreg_n[0]}"
        dreg_n[0] += 1
        return r
 
    def ireg():
        if ireg_n[0] > 10:
            raise RuntimeError("Registradores inteiros esgotados (máx r10).")
        r = f"r{ireg_n[0]}"
        ireg_n[0] += 1
        return r
 
    def emit(line): code.append(line)
    def note(msg):  code.append(f"    @ {msg}")
 
    def is_number(t):
        try:    float(t); return True
        except: return False
 
    def is_mem(t):
        return bool(re.fullmatch(r"[A-Z]+", t)) and t != "RES"
 
    def const_label(value_str):
        if value_str not in const_pool:
            lbl = new_label("C")
            const_pool[value_str] = lbl
            data.append(f"{lbl}:  .double {value_str}")
        return const_pool[value_str]
 
    def mem_label(name):
        if name not in mem_vars:
            mem_vars.add(name)
            data.append(f"MEM_{name}:  .double 0.0  @ variável {name}")
        return f"MEM_{name}"
 
    # ------------------------------------------------------------------
    # sreg_low: retorna o s-registrador de 32 bits correspondente à
    # metade BAIXA de um d-registrador.
    # Regra: dN → s(2N)   (ex: d0→s0, d1→s2, d3→s6)
    # É nessa metade que VCVT.S32.F64 deposita o inteiro convertido.
    # ------------------------------------------------------------------
    def sreg_low(dn: str) -> str:
        n = int(dn[1:])
        return f"s{2 * n}"
 
    # ------------------------------------------------------------------
    # Conversão double → inteiro (resultado em r-reg)
    # Usa d14 como temporário fixo para o VCVT (não conflita com
    # os d-regs da expressão, que vão até d13).
    # ------------------------------------------------------------------
    def double_to_int(dn: str, rn: str):
        """
        Converte o double em `dn` para inteiro em `rn`.
        Sequência correta para Cortex-A9 VFPv3:
          VCVT.S32.F64 s_tmp, dn   (converte; resultado vai para s-reg)
          VMOV         rn, s_tmp   (copia s-reg → r-reg)
        Usamos s28 (= metade baixa de d14) como s-reg temporário.
        """
        note(f"double→int: {dn} → {rn}")
        emit(f"    VCVT.S32.F64 s28, {dn}")   # s28 = metade baixa de d14
        emit(f"    VMOV         {rn}, s28")
 
    # ------------------------------------------------------------------
    # Divisão inteira via FPU (sem SDIV/UDIV — não disponível no A9/ARM)
    # resultado = trunc(a / b)
    # ------------------------------------------------------------------
    def fpu_idiv(da: str, db: str, dr: str, rr: str):
        """
        Divide os doubles `da` e `db`, trunca para inteiro.
        Coloca o resultado double em `dr` e inteiro em `rr`.
        """
        note(f"divisão inteira FPU: {da} // {db} → {dr} ({rr})")
        emit(f"    VDIV.F64    {dr}, {da}, {db}")
        double_to_int(dr, rr)
 
    # ------------------------------------------------------------------
    # Conversão de tipos entre operandos da pilha
    # ------------------------------------------------------------------
 
    def to_float(op):
        """Garante que o operando está em d-reg float."""
        if op["kind"] == "float":
            return op
        # int → float: copia r-reg → s-reg, converte s→d
        d = dreg()
        note(f"int→float: {op['reg']} → {d}")
        emit(f"    VMOV         {sreg_low(d)}, {op['reg']}")
        emit(f"    VCVT.F64.S32 {d}, {sreg_low(d)}")
        return {"reg": d, "kind": "float"}
 
    def to_int(op):
        """Garante que o operando está em r-reg inteiro."""
        if op["kind"] == "int":
            return op
        r = ireg()
        double_to_int(op["reg"], r)
        return {"reg": r, "kind": "int"}
 
    # ------------------------------------------------------------------
    # Carregamento de valores
    # ------------------------------------------------------------------
 
    def load_number(value_str):
        lbl = const_label(value_str)
        d   = dreg()
        r   = ireg()
        note(f"carrega {value_str} → {d}")
        emit(f"    LDR     {r}, ={lbl}")
        emit(f"    VLDR    {d}, [{r}]")
        stack.append({"reg": d, "kind": "float"})
 
    def load_mem(name):
        lbl = mem_label(name)
        d   = dreg()
        r   = ireg()
        note(f"lê {name} → {d}")
        emit(f"    LDR     {r}, ={lbl}")
        emit(f"    VLDR    {d}, [{r}]")
        stack.append({"reg": d, "kind": "float"})
 
    def store_mem(name):
        if not stack:
            raise RuntimeError(f"Pilha vazia ao gravar em {name}.")
        op  = stack[-1]
        lbl = mem_label(name)
        r   = ireg()
        note(f"grava {op['reg']} → {name}")
        emit(f"    LDR     {r}, ={lbl}")
        if op["kind"] == "float":
            emit(f"    VSTR    {op['reg']}, [{r}]")
        else:
            # int → s-reg → double → grava
            tmp = dreg()
            emit(f"    VMOV         {sreg_low(tmp)}, {op['reg']}")
            emit(f"    VCVT.F64.S32 {tmp}, {sreg_low(tmp)}")
            emit(f"    VSTR         {tmp}, [{r}]")
 
    def load_res(n):
        if n >= len(history):
            raise RuntimeError(f"RES({n}): sem resultado {n} posição(ões) atrás.")
        past = history[n]
        if past["kind"] == "float":
            d = dreg()
            note(f"RES({n}): copia {past['reg']} → {d}")
            emit(f"    VMOV    {d}, {past['reg']}")
            stack.append({"reg": d, "kind": "float"})
        else:
            r = ireg()
            note(f"RES({n}): copia {past['reg']} → {r}")
            emit(f"    MOV     {r}, {past['reg']}")
            stack.append({"reg": r, "kind": "int"})
 
    # ------------------------------------------------------------------
    # Operações aritméticas
    # ------------------------------------------------------------------
 
    def float_op(op):
        if len(stack) < 2:
            raise RuntimeError(f"Pilha insuficiente para '{op}'.")
        b = to_float(stack.pop())
        a = to_float(stack.pop())
        d = dreg()
        instr = {"+": "VADD.F64", "-": "VSUB.F64",
                 "*": "VMUL.F64", "/": "VDIV.F64"}[op]
        note(f"{a['reg']} {op} {b['reg']} → {d}")
        emit(f"    {instr}  {d}, {a['reg']}, {b['reg']}")
        result = {"reg": d, "kind": "float"}
        stack.append(result)
        history.insert(0, result)
 
    def pow_op():
        if len(stack) < 2:
            raise RuntimeError("Pilha insuficiente para '^'.")
        exp_op = stack.pop()
        base   = to_float(stack.pop())
        # expoente: converte para inteiro em r-reg para usar como contador
        exp_r  = ireg()
        if exp_op["kind"] == "float":
            double_to_int(exp_op["reg"], exp_r)
        else:
            emit(f"    MOV     {exp_r}, {exp_op['reg']}")
        d   = dreg()
        cnt = ireg()
        r1  = ireg()
        one = const_label("1.0")
        lp  = new_label("POW_LP")
        end = new_label("POW_END")
        note(f"{base['reg']} ^ {exp_r} → {d}")
        emit(f"    LDR      {r1}, ={one}")
        emit(f"    VLDR     {d}, [{r1}]")       # acumulador = 1.0
        emit(f"    MOV      {cnt}, {exp_r}")
        emit(f"{lp}:")
        emit(f"    CMP      {cnt}, #0")
        emit(f"    BLE      {end}")
        emit(f"    VMUL.F64 {d}, {d}, {base['reg']}")
        emit(f"    SUB      {cnt}, {cnt}, #1")
        emit(f"    B        {lp}")
        emit(f"{end}:")
        result = {"reg": d, "kind": "float"}
        stack.append(result)
        history.insert(0, result)
 
    def int_op(op):
        """
        Divisão inteira (//) e módulo (%) via FPU.
        Cortex-A9 em modo ARM não possui SDIV/UDIV.
        Algoritmo:
          q_double = VDIV(a_double, b_double)
          q_int    = VCVT truncado (arredonda em direção a zero)
          se op == %: resto = a_int - q_int * b_int
        """
        if len(stack) < 2:
            raise RuntimeError(f"Pilha insuficiente para '{op}'.")
 
        b_raw = stack.pop()
        a_raw = stack.pop()
        a = to_float(a_raw)
        b = to_float(b_raw)
 
        dq = dreg()    # quociente double
        rq = ireg()    # quociente inteiro
        fpu_idiv(a["reg"], b["reg"], dq, rq)
 
        if op == "//":
            result = {"reg": rq, "kind": "int"}
            stack.append(result)
            history.insert(0, result)
 
        else:  # %  →  resto = a - q * b  (tudo double para depois truncar)
            # q_double já está em dq; converte de volta para double limpo
            dq_clean = dreg()
            note("módulo: reconverte quociente truncado → double")
            emit(f"    VMOV         {sreg_low(dq_clean)}, {rq}")
            emit(f"    VCVT.F64.S32 {dq_clean}, {sreg_low(dq_clean)}")
            # resto_double = a - q_double_clean * b
            dprod  = dreg()
            dresto = dreg()
            emit(f"    VMUL.F64 {dprod}, {dq_clean}, {b['reg']}")
            emit(f"    VSUB.F64 {dresto}, {a['reg']}, {dprod}")
            # trunca resto para inteiro
            rresto = ireg()
            double_to_int(dresto, rresto)
            result = {"reg": rresto, "kind": "int"}
            stack.append(result)
            history.insert(0, result)
 
    # ------------------------------------------------------------------
    # Seven segment display
    # ------------------------------------------------------------------
 
    def emit_seven_seg(val_reg: str):
        """
        Exibe o inteiro em `val_reg` nos displays HEX0–HEX5.
 
        Divisão por 10 também é feita via FPU (sem UDIV).
        Usa d15 como double temporário e s30 como s-reg temporário.
        Registradores de display: r0-r7 (reutilizados após a expressão).
        """
        lbl_pos  = new_label("SEG_POS")
        lbl_loop = new_label("SEG_LOOP")
        lbl_done = new_label("SEG_DONE")
        lbl_hi   = new_label("SEG_HI")
        lbl_next = new_label("SEG_NEXT")
 
        # Scratch registers fixos para a rotina de display
        rV   = "r0"   # valor absoluto atual
        rB   = "r1"   # base da tabela SEG7_TABLE
        rD   = "r2"   # dígito corrente (0–9)
        rSeg = "r3"   # código de segmento do dígito
        rA   = "r4"   # endereço do registrador de display
        rTmp = "r5"   # scratch
        rIdx = "r6"   # índice do display (0–5)
        # d15 / s30 são os temporários VFP da rotina de display
 
        note("=== seven segment display ===")
        note(f"copia {val_reg} → {rV}")
        emit(f"    MOV     {rV}, {val_reg}")
 
        # Limpa todos os displays
        note("limpa HEX0-HEX3 e HEX4-HEX5")
        emit(f"    LDR     {rA}, =0xFF200020")
        emit(f"    MOV     {rTmp}, #0")
        emit(f"    STR     {rTmp}, [{rA}]")
        emit(f"    LDR     {rA}, =0xFF200030")
        emit(f"    STR     {rTmp}, [{rA}]")
 
        # Sinal negativo
        note("testa sinal")
        emit(f"    CMP     {rV}, #0")
        emit(f"    BGE     {lbl_pos}")
        note("negativo: abs e traço em HEX5")
        emit(f"    RSB     {rV}, {rV}, #0")
        emit(f"    LDR     {rA}, =0xFF200030")
        emit(f"    MOV     {rTmp}, #0x40")
        emit(f"    LSL     {rTmp}, {rTmp}, #8")   # traço na posição HEX5
        emit(f"    STR     {rTmp}, [{rA}]")
        emit(f"{lbl_pos}:")
 
        # Prepara loop
        emit(f"    LDR     {rB}, =SEG7_TABLE")
        emit(f"    MOV     {rIdx}, #0")
 
        emit(f"{lbl_loop}:")
        emit(f"    CMP     {rIdx}, #6")
        emit(f"    BGE     {lbl_done}")
 
        # dígito = rV % 10  via FPU:
        #   d15 = (double) rV
        #   d15 = VDIV(d15, 10.0)   → quociente real
        #   VCVT trunca → s30 → rTmp  (= rV // 10)
        #   dígito = rV - rTmp * 10
        lbl_ten = const_label("10.0")
        note("extrai próximo dígito via FPU")
        emit(f"    VMOV         s30, {rV}")
        emit(f"    VCVT.F64.S32 d15, s30")          # d15 = (double) rV
        emit(f"    LDR          {rTmp}, ={lbl_ten}")
        emit(f"    VLDR         d14, [{rTmp}]")      # d14 = 10.0
        emit(f"    VDIV.F64     d15, d15, d14")      # d15 = rV / 10.0
        emit(f"    VCVT.S32.F64 s30, d15")           # s30 = trunc(rV/10)
        emit(f"    VMOV         {rTmp}, s30")         # rTmp = quociente inteiro
        emit(f"    MUL          {rD}, {rTmp}, r7")    # rD  = quot * 10  (r7 conterá 10)
 
        # Precisamos de 10 em um r-reg para o MUL — usamos r7
        emit(f"    MOV     r7, #10")
        emit(f"    MUL     {rD}, {rTmp}, r7")         # rD = (rV//10) * 10
        emit(f"    SUB     {rD}, {rV}, {rD}")         # rD = rV - quot*10 = dígito
        emit(f"    MOV     {rV}, {rTmp}")             # rV = rV // 10  (próxima iteração)
 
        # Busca código do segmento
        emit(f"    LDRB    {rSeg}, [{rB}, {rD}]")
 
        # Empacota no registrador correto do display
        note("empacota dígito no display correto")
        emit(f"    CMP     {rIdx}, #4")
        emit(f"    BGE     {lbl_hi}")
 
        # HEX0–HEX3 → 0xFF200020
        emit(f"    MOV     {rTmp}, {rIdx}")
        emit(f"    LSL     {rTmp}, {rTmp}, #3")       # deslocamento = idx * 8 bits
        emit(f"    LSL     {rSeg}, {rSeg}, {rTmp}")
        emit(f"    LDR     {rA}, =0xFF200020")
        emit(f"    LDR     {rTmp}, [{rA}]")
        emit(f"    ORR     {rTmp}, {rTmp}, {rSeg}")
        emit(f"    STR     {rTmp}, [{rA}]")
        emit(f"    B       {lbl_next}")
 
        # HEX4–HEX5 → 0xFF200030
        emit(f"{lbl_hi}:")
        emit(f"    SUB     {rTmp}, {rIdx}, #4")
        emit(f"    LSL     {rTmp}, {rTmp}, #3")
        emit(f"    LSL     {rSeg}, {rSeg}, {rTmp}")
        emit(f"    LDR     {rA}, =0xFF200030")
        emit(f"    LDR     {rTmp}, [{rA}]")
        emit(f"    ORR     {rTmp}, {rTmp}, {rSeg}")
        emit(f"    STR     {rTmp}, [{rA}]")
 
        emit(f"{lbl_next}:")
        emit(f"    ADD     {rIdx}, {rIdx}, #1")
        emit(f"    CMP     {rV}, #0")
        emit(f"    BNE     {lbl_loop}")
 
        emit(f"{lbl_done}:")
        note("=== display atualizado ===")
 
    # ------------------------------------------------------------------
    # Loop principal
    # ------------------------------------------------------------------
    i = 0
    while i < len(tokens):
        tok = tokens[i]
 
        if is_number(tok):
            load_number(tok)
            i += 1
 
        elif tok in ("+", "-", "*", "/"):
            float_op(tok)
            i += 1
 
        elif tok == "^":
            pow_op()
            i += 1
 
        elif tok in ("//", "%"):
            int_op(tok)
            i += 1
 
        elif tok == "RES":
            if i + 1 >= len(tokens) or not is_number(tokens[i + 1]):
                raise ValueError("RES precisa ser seguido de um número inteiro.")
            load_res(int(float(tokens[i + 1])))
            i += 2
 
        elif is_mem(tok):
            prev_is_value = i > 0 and (
                is_number(tokens[i - 1])
                or tokens[i - 1] in ("+", "-", "*", "/", "^", "//", "%")
                or is_mem(tokens[i - 1])
            )
            if stack and prev_is_value:
                store_mem(tok)
                history.insert(0, stack[-1])
            else:
                load_mem(tok)
            i += 1
 
        else:
            raise ValueError(f"Token desconhecido: '{tok}'")
 
    # ------------------------------------------------------------------
    # Converte resultado para inteiro e chama o display
    # ------------------------------------------------------------------
    if not stack:
        raise RuntimeError("Pilha vazia — expressão não produziu resultado.")
 
    final    = stack[-1]
    int_res  = to_int(final)
 
    emit("")
    emit_seven_seg(int_res["reg"])
 
    # Tabela de segmentos no .data
    data.append("")
    data.append("@ gfedcba: dígitos 0-9")
    seg_bytes = ", ".join(f"0x{v:02X}" for v in SEG7_DIGITS)
    data.append(f"SEG7_TABLE:  .byte {seg_bytes}")
    data.append(f"             .byte 0x{SEG7_BLANK:02X}   @ vazio")
    data.append(f"             .byte 0x{SEG7_MINUS:02X}   @ traço")
    data.append("             .align 2")
 
    # ------------------------------------------------------------------
    # Monta saída final
    # ------------------------------------------------------------------
    partes = [
        "@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)",
        f"@ Expressão RPN: {' '.join(tokens)}",
        ".global _start",
        "",
    ]
 
    if data:
        partes += [".section .data", ""] + data + [""]
 
    partes += [
        ".section .text",
        "_start:",
        "",
    ] + code + [
        "",
        f"    @ resultado final em {final['reg']} ({final['kind']})",
        "    B   .   @ halt",
    ]
 
    return "\n".join(partes)
 


def exibirResultados(resultados):
    for resultado in resultados:
        print(f"O resultado é {resultado}!")


# main
def main():
    # Se chamado com --test, roda os testes do analisador léxico
    if len(sys.argv) == 2 and sys.argv[1] == "--test":
        testar_analisador_lexico()
        return

    # Se chamado com --test-expr, roda os testes de execução de expressões
    if len(sys.argv) == 2 and sys.argv[1] == "--test-expr":
        testar_executar_expressao()
        return

    if len(sys.argv) != 2:
        print("Uso: python main.py <arquivo_de_teste>")
        print("     python main.py --test  (para rodar testes)")
        sys.exit(1)

    nome_arquivo = sys.argv[1]
    linhas_expressoes = lerArquivo(nomeArquivo=nome_arquivo)
    for linha in linhas_expressoes:
        parseExpressao(linha=linha, )
    print(f"Arquivo: {nome_arquivo}")
    print("(Integração completa será feita quando todas as partes estiverem prontas)")


if __name__ == "__main__":
    main()