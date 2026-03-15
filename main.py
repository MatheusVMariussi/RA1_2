# Trabalho RA1, Grupo 2
# Alunos: (Deixar em ordem alfabética)
# - Jorge Samuel Teixeira Jordão, JorgeSTJordao
# - Matheus Vinius Mariussi, MatheusVMariussi
# - Pedro Henrique Vargas Navarro, Navarro45
# - Nome do Aluno 4, Nome do github 4

import sys
import re
from testesAnalisadorLexico import testar_analisador_lexico

# TODO (serão implementados pelos outros membros do grupo)

def lerArquivo(nomeArquivo):
    linhas = []

    with open(nomeArquivo, "r", encoding="utf-8") as arquivo:
        for linha in arquivo:
            linhas.append(linha.strip())

    return linhas

def executarExpressao(tokens, resultados, memoria):
    # Avalia a expressão RPN representada por tokens
    pilha = []
    resultado = None
    for token in tokens:
        if token.tipo == 'NUMBER':
            pilha.append(float(token.valor))
        elif token.tipo == 'MEM_NAME':
            nome = token.valor
            if pilha:
                # Há valor na pilha: armazenar na memória (WRITE)
                memoria[nome] = pilha.pop()
            elif nome in memoria:
                # Pilha vazia: ler da memória (READ)
                pilha.append(memoria[nome])
            else:
                raise ValueError(f"Variável '{nome}' não encontrada na memória.")
        elif token.tipo == 'OP_ADD':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(a + b)
        elif token.tipo == 'OP_SUB':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(a - b)
        elif token.tipo == 'OP_MUL':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(a * b)
        elif token.tipo == 'OP_DIV':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(a / b)
        elif token.tipo == 'OP_INTDIV':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(int(a // b))
        elif token.tipo == 'OP_MOD':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(int(a % b))
        elif token.tipo == 'OP_POW':
            b = pilha.pop()
            a = pilha.pop()
            pilha.append(a ** b)
        elif token.tipo == 'KEYWORD_RES':
            resultado = pilha[-1] if pilha else None
            resultados.append(resultado)
        elif token.tipo == 'LPAREN' or token.tipo == 'RPAREN':
            # Parênteses são tratados no parser, ignorar aqui
            continue
    # Atualiza resultado final
    if resultado is None and pilha:
        resultado = pilha[-1]
        resultados.append(resultado)
    return resultado

def gerarAssembly(tokens: list[str]) -> str:
    
    if not tokens:
        raise ValueError("Lista de tokens vazia.")
 
    # ------------------------------------------------------------------
    # Estado interno
    # ------------------------------------------------------------------
    code       = []   # linhas de código assembly (.text)
    data       = []   # linhas da seção .data
    stack      = []   # pilha: {"reg": str, "kind": "float"|"int"}
    history    = []   # histórico de resultados para RES
    const_pool = {}   # valor_str -> label  (evita duplicatas no .data)
    mem_vars   = set()# nomes de variáveis já declaradas
    label_n    = [0]  # contador global de labels
    dreg_n     = [0]  # próximo registrador VFP  livre (d0-d15)
    ireg_n     = [0]  # próximo registrador int. livre (r0-r12)
 
    # ------------------------------------------------------------------
    # Funções auxiliares
    # ------------------------------------------------------------------
 
    def new_label(prefix="L"):
        lbl = f"{prefix}{label_n[0]}"
        label_n[0] += 1
        return lbl
 
    def dreg():
        if dreg_n[0] > 15:
            raise RuntimeError("Registradores VFP esgotados (máx d15).")
        r = f"d{dreg_n[0]}"
        dreg_n[0] += 1
        return r
 
    def ireg():
        if ireg_n[0] > 12:
            raise RuntimeError("Registradores inteiros esgotados (máx r12).")
        r = f"r{ireg_n[0]}"
        ireg_n[0] += 1
        return r
 
    def emit(line):
        code.append(line)
 
    def note(msg):
        code.append(f"    @ {msg}")
 
    def is_number(t):
        try:
            float(t)
            return True
        except ValueError:
            return False
 
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
 
    def to_float(op):
        if op["kind"] == "float":
            return op
        d = dreg()
        note(f"int->float: {op['reg']} -> {d}")
        emit(f"    VMOV    {d}, {op['reg']}")
        emit(f"    VCVT.F64.S32 {d}, {d}")
        return {"reg": d, "kind": "float"}
 
    def to_int(op):
        if op["kind"] == "int":
            return op
        tmp = dreg()
        r   = ireg()
        note(f"float->int: {op['reg']} -> {r}")
        emit(f"    VCVT.S32.F64 {tmp}, {op['reg']}")
        emit(f"    VMOV    {r}, {tmp}")
        return {"reg": r, "kind": "int"}
 
    def load_number(value_str):
        lbl = const_label(value_str)
        d   = dreg()
        r   = ireg()
        note(f"carrega {value_str} -> {d}")
        emit(f"    LDR     {r}, ={lbl}")
        emit(f"    VLDR    {d}, [{r}]")
        stack.append({"reg": d, "kind": "float"})
 
    def load_mem(name):
        lbl = mem_label(name)
        d   = dreg()
        r   = ireg()
        note(f"lê {name} -> {d}")
        emit(f"    LDR     {r}, ={lbl}")
        emit(f"    VLDR    {d}, [{r}]")
        stack.append({"reg": d, "kind": "float"})
 
    def store_mem(name):
        if not stack:
            raise RuntimeError(f"Pilha vazia ao gravar em {name}.")
        op  = stack[-1]
        lbl = mem_label(name)
        r   = ireg()
        note(f"grava {op['reg']} -> {name}")
        emit(f"    LDR     {r}, ={lbl}")
        if op["kind"] == "float":
            emit(f"    VSTR    {op['reg']}, [{r}]")
        else:
            tmp = dreg()
            emit(f"    VMOV    {tmp}, {op['reg']}")
            emit(f"    VCVT.F64.S32 {tmp}, {tmp}")
            emit(f"    VSTR    {tmp}, [{r}]")
 
    def float_op(op):
        if len(stack) < 2:
            raise RuntimeError(f"Pilha insuficiente para '{op}'.")
        b = to_float(stack.pop())
        a = to_float(stack.pop())
        d = dreg()
        instr = {"+": "VADD.F64", "-": "VSUB.F64",
                 "*": "VMUL.F64", "/": "VDIV.F64"}[op]
        note(f"{a['reg']} {op} {b['reg']} -> {d}")
        emit(f"    {instr}  {d}, {a['reg']}, {b['reg']}")
        result = {"reg": d, "kind": "float"}
        stack.append(result)
        history.insert(0, result)
 
    def pow_op():
        if len(stack) < 2:
            raise RuntimeError("Pilha insuficiente para '^'.")
        exp  = to_int(stack.pop())
        base = to_float(stack.pop())
        d    = dreg()
        cnt  = ireg()
        r1   = ireg()
        one  = const_label("1.0")
        lp   = new_label("POW_LP")
        end  = new_label("POW_END")
        note(f"{base['reg']} ^ {exp['reg']} -> {d}")
        emit(f"    LDR     {r1}, ={one}")
        emit(f"    VLDR    {d}, [{r1}]")
        emit(f"    MOV     {cnt}, {exp['reg']}")
        emit(f"{lp}:")
        emit(f"    CMP     {cnt}, #0")
        emit(f"    BLE     {end}")
        emit(f"    VMUL.F64 {d}, {d}, {base['reg']}")
        emit(f"    SUB     {cnt}, {cnt}, #1")
        emit(f"    B       {lp}")
        emit(f"{end}:")
        result = {"reg": d, "kind": "float"}
        stack.append(result)
        history.insert(0, result)
 
    def int_op(op):
        if len(stack) < 2:
            raise RuntimeError(f"Pilha insuficiente para '{op}'.")
        b   = to_int(stack.pop())
        a   = to_int(stack.pop())
        res = ireg()
        if op == "//":
            note(f"{a['reg']} // {b['reg']} -> {res}")
            emit(f"    SDIV    {res}, {a['reg']}, {b['reg']}")
        else:
            q   = ireg()
            tmp = ireg()
            note(f"{a['reg']} % {b['reg']} -> {res}")
            emit(f"    SDIV    {q}, {a['reg']}, {b['reg']}")
            emit(f"    MUL     {tmp}, {q}, {b['reg']}")
            emit(f"    SUB     {res}, {a['reg']}, {tmp}")
        result = {"reg": res, "kind": "int"}
        stack.append(result)
        history.insert(0, result)
 
    def load_res(n):
        if n >= len(history):
            raise RuntimeError(f"RES({n}): sem resultado {n} posição(ões) atrás.")
        past = history[n]
        if past["kind"] == "float":
            d = dreg()
            note(f"RES({n}): copia {past['reg']} -> {d}")
            emit(f"    VMOV    {d}, {past['reg']}")
            stack.append({"reg": d, "kind": "float"})
        else:
            r = ireg()
            note(f"RES({n}): copia {past['reg']} -> {r}")
            emit(f"    MOV     {r}, {past['reg']}")
            stack.append({"reg": r, "kind": "int"})
 
    # ------------------------------------------------------------------
    # Loop principal — percorre os tokens
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
            # "valor NOME" -> armazena; "NOME" sozinho -> lê
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
    # Monta o assembly final
    # ------------------------------------------------------------------
    if not stack:
        raise RuntimeError("Pilha vazia — expressão não produziu resultado.")
 
    final = stack[-1]
 
    partes = [
        "@ Gerado automaticamente — ARMv7 DE1-SoC (CPUlator)",
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
    # Exibe os resultados formatados no console
    pass


# main
def main():
    # Se chamado com --test, roda os testes do analisador léxico
    if len(sys.argv) == 2 and sys.argv[1] == "--test":
        testar_analisador_lexico()
        return

    # Se chamado com --test-expr, roda os testes de execução de expressões
    if len(sys.argv) == 2 and sys.argv[1] == "--test-expr":
        from testesExecutarExpressao import testar_executar_expressao
        testar_executar_expressao()
        return

    if len(sys.argv) != 2:
        print("Uso: python main.py <arquivo_de_teste>")
        print("     python main.py --test  (para rodar testes)")
        sys.exit(1)

    nome_arquivo = sys.argv[1]
    print(f"Arquivo: {nome_arquivo}")
    print("(Integração completa será feita quando todas as partes estiverem prontas)")


if __name__ == "__main__":
    main()