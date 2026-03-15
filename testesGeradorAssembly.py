
import unittest
from main import gerarAssembly


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def instrucoes(asm: str) -> list[str]:
    """Retorna apenas as linhas que contêm instruções (sem comentários e labels)."""
    linhas = []
    for linha in asm.splitlines():
        s = linha.strip()
        if s and not s.startswith("@") and not s.startswith(".") and not s.endswith(":"):
            # Remove comentário inline e espaços extras
            s = s.split("@")[0].strip()
            if s:
                linhas.append(s)
    return linhas


def tem_instrucao(asm: str, prefixo: str) -> bool:
    """Verifica se alguma instrução gerada começa com o prefixo dado."""
    return any(linha.startswith(prefixo) for linha in instrucoes(asm))


# ---------------------------------------------------------------------------
# Testes de estrutura básica
# ---------------------------------------------------------------------------

class TesteEstrutura(unittest.TestCase):

    def test_contem_global_start(self):
        """Todo assembly gerado deve exportar _start."""
        asm = gerarAssembly(["1.0", "2.0", "+"])
        self.assertIn(".global _start", asm)

    def test_contem_label_start(self):
        """Deve haver o ponto de entrada _start:"""
        asm = gerarAssembly(["1.0", "2.0", "+"])
        self.assertIn("_start:", asm)

    def test_contem_halt(self):
        """Deve terminar com B . (loop infinito / halt)."""
        asm = gerarAssembly(["1.0", "2.0", "+"])
        self.assertIn("B   .", asm)

    def test_contem_secao_text(self):
        """Deve haver a seção .text."""
        asm = gerarAssembly(["1.0", "2.0", "+"])
        self.assertIn(".section .text", asm)

    def test_contem_secao_data_quando_ha_constante(self):
        """Deve haver .section .data quando existem literais numéricos."""
        asm = gerarAssembly(["3.0", "4.0", "*"])
        self.assertIn(".section .data", asm)

    def test_resultado_final_comentado(self):
        """Deve indicar em comentário qual registrador tem o resultado."""
        asm = gerarAssembly(["5.0", "2.0", "-"])
        self.assertIn("resultado final", asm)

    def test_tokens_vazios_lanca_erro(self):
        """Lista vazia deve lançar ValueError."""
        with self.assertRaises(ValueError):
            gerarAssembly([])


# ---------------------------------------------------------------------------
# Testes de carregamento de literais
# ---------------------------------------------------------------------------

class TesteCarregamento(unittest.TestCase):

    def test_literal_gera_ldr_e_vldr(self):
        """Carregar um número deve gerar LDR (endereço) e VLDR (valor)."""
        asm = gerarAssembly(["7.0", "2.0", "+"])
        self.assertTrue(tem_instrucao(asm, "LDR"))
        self.assertTrue(tem_instrucao(asm, "VLDR"))

    def test_literal_declarado_no_data(self):
        """O valor literal deve aparecer como .double na seção .data."""
        asm = gerarAssembly(["9.5", "1.5", "+"])
        self.assertIn(".double 9.5", asm)
        self.assertIn(".double 1.5", asm)

    def test_literais_duplicados_nao_duplicam_no_data(self):
        """O mesmo valor literal não deve aparecer duas vezes no .data."""
        asm = gerarAssembly(["3.0", "3.0", "+"])
        self.assertEqual(asm.count(".double 3.0"), 1)

    def test_numero_inteiro_como_token(self):
        """Tokens como '5' (sem ponto) também devem ser aceitos."""
        asm = gerarAssembly(["5", "3", "+"])
        self.assertIn("VADD.F64", asm)


# ---------------------------------------------------------------------------
# Testes de operações float
# ---------------------------------------------------------------------------

class TesteOperacoesFloat(unittest.TestCase):

    def test_adicao(self):
        """5.0 + 3.0 deve gerar VADD.F64."""
        asm = gerarAssembly(["5.0", "3.0", "+"])
        self.assertIn("VADD.F64", asm)

    def test_subtracao(self):
        """9.0 - 4.0 deve gerar VSUB.F64."""
        asm = gerarAssembly(["9.0", "4.0", "-"])
        self.assertIn("VSUB.F64", asm)

    def test_multiplicacao(self):
        """6.0 * 7.0 deve gerar VMUL.F64."""
        asm = gerarAssembly(["6.0", "7.0", "*"])
        self.assertIn("VMUL.F64", asm)

    def test_divisao(self):
        """10.0 / 2.0 deve gerar VDIV.F64."""
        asm = gerarAssembly(["10.0", "2.0", "/"])
        self.assertIn("VDIV.F64", asm)

    def test_resultado_float_no_banco_vfp(self):
        """O resultado de uma operação float deve estar em um registrador d."""
        asm = gerarAssembly(["4.0", "2.0", "+"])
        # Comentário de resultado deve mencionar um registrador d
        linha_resultado = [l for l in asm.splitlines() if "resultado final" in l][0]
        self.assertIn(" d", linha_resultado)

    def test_pilha_insuficiente_lanca_erro(self):
        """Operador sem dois operandos deve lançar RuntimeError."""
        with self.assertRaises(RuntimeError):
            gerarAssembly(["5.0", "+"])


# ---------------------------------------------------------------------------
# Testes de expressões aninhadas
# ---------------------------------------------------------------------------

class TesteExpressoesAninhadas(unittest.TestCase):

    def test_tres_operandos_soma_encadeada(self):
        """1 + 2 + 3 → tokens ['1.0','2.0','+','3.0','+'] → dois VADD."""
        asm = gerarAssembly(["1.0", "2.0", "+", "3.0", "+"])
        self.assertEqual(asm.count("VADD.F64"), 2)

    def test_soma_depois_multiplicacao(self):
        """(2+3) * 4 → tokens ['2.0','3.0','+','4.0','*']."""
        asm = gerarAssembly(["2.0", "3.0", "+", "4.0", "*"])
        self.assertIn("VADD.F64", asm)
        self.assertIn("VMUL.F64", asm)

    def test_divisao_de_somas(self):
        """(2+3) / (4+1) → tokens ['2.0','3.0','+','4.0','1.0','+','/']."""
        asm = gerarAssembly(["2.0", "3.0", "+", "4.0", "1.0", "+", "/"])
        self.assertIn("VADD.F64", asm)
        self.assertIn("VDIV.F64", asm)

    def test_quatro_operandos(self):
        """(A+B) / (C*D) → deve gerar ADD, MUL e DIV."""
        asm = gerarAssembly(["2.0", "3.0", "+", "4.0", "5.0", "*", "/"])
        self.assertIn("VADD.F64", asm)
        self.assertIn("VMUL.F64", asm)
        self.assertIn("VDIV.F64", asm)

    def test_registradores_distintos_por_operacao(self):
        """Cada resultado intermediário deve usar um registrador d diferente."""
        asm = gerarAssembly(["1.0", "2.0", "+", "3.0", "4.0", "+", "*"])
        # Deve haver pelo menos d0, d1, d2 sendo usados
        self.assertIn("d0", asm)
        self.assertIn("d1", asm)
        self.assertIn("d2", asm)


# ---------------------------------------------------------------------------
# Testes de potenciação
# ---------------------------------------------------------------------------

class TestePotenciacao(unittest.TestCase):

    def test_potencia_gera_loop(self):
        """2^8 deve gerar labels de loop (POW_LP e POW_END)."""
        asm = gerarAssembly(["2.0", "8.0", "^"])
        self.assertIn("POW_LP", asm)
        self.assertIn("POW_END", asm)

    def test_potencia_usa_vmul(self):
        """O loop de potenciação deve usar VMUL.F64."""
        asm = gerarAssembly(["2.0", "8.0", "^"])
        self.assertIn("VMUL.F64", asm)

    def test_potencia_inicializa_com_1(self):
        """O acumulador de potência deve ser inicializado com 1.0."""
        asm = gerarAssembly(["3.0", "4.0", "^"])
        self.assertIn(".double 1.0", asm)

    def test_potencia_converte_expoente_para_inteiro(self):
        """O expoente (float) deve ser convertido para int via VCVT.S32.F64."""
        asm = gerarAssembly(["2.0", "3.0", "^"])
        self.assertIn("VCVT.S32.F64", asm)

    def test_potencia_pilha_insuficiente(self):
        """^ sem dois operandos deve lançar RuntimeError."""
        with self.assertRaises(RuntimeError):
            gerarAssembly(["2.0", "^"])


# ---------------------------------------------------------------------------
# Testes de operações inteiras
# ---------------------------------------------------------------------------

class TesteOperacoesInteiras(unittest.TestCase):

    def test_divisao_inteira_gera_sdiv(self):
        """17 // 5 deve gerar SDIV."""
        asm = gerarAssembly(["17.0", "5.0", "//"])
        self.assertIn("SDIV", asm)

    def test_modulo_gera_sdiv_mul_sub(self):
        """17 % 5 deve gerar SDIV + MUL + SUB (fórmula do módulo)."""
        asm = gerarAssembly(["17.0", "5.0", "%"])
        self.assertIn("SDIV", asm)
        self.assertIn("MUL", asm)
        self.assertIn("SUB", asm)

    def test_operacao_inteira_converte_floats(self):
        """Operandos float passados para // devem ser convertidos (VCVT.S32.F64)."""
        asm = gerarAssembly(["10.0", "3.0", "//"])
        self.assertIn("VCVT.S32.F64", asm)

    def test_resultado_inteiro_em_registrador_r(self):
        """O resultado de // deve estar em um registrador r."""
        asm = gerarAssembly(["10.0", "3.0", "//"])
        linha_resultado = [l for l in asm.splitlines() if "resultado final" in l][0]
        self.assertIn(" r", linha_resultado)

    def test_divisao_inteira_pilha_insuficiente(self):
        with self.assertRaises(RuntimeError):
            gerarAssembly(["5.0", "//"])

    def test_modulo_pilha_insuficiente(self):
        with self.assertRaises(RuntimeError):
            gerarAssembly(["5.0", "%"])


# ---------------------------------------------------------------------------
# Testes de variáveis de memória
# ---------------------------------------------------------------------------

class TesteMemoria(unittest.TestCase):

    def test_leitura_de_variavel_gera_vldr(self):
        """Ler uma variável deve gerar VLDR."""
        asm = gerarAssembly(["VAR", "2.0", "+"])
        self.assertIn("VLDR", asm)

    def test_leitura_declara_no_data(self):
        """Variável lida deve ser declarada no .data com valor 0.0."""
        asm = gerarAssembly(["X", "1.0", "+"])
        self.assertIn("MEM_X", asm)
        self.assertIn(".double 0.0", asm)

    def test_escrita_gera_vstr(self):
        """Gravar em variável deve gerar VSTR."""
        asm = gerarAssembly(["5.0", "VAR", "VAR", "1.0", "+"])
        self.assertIn("VSTR", asm)

    def test_escrita_nao_remove_da_pilha(self):
        """Após gravar em variável, o valor ainda deve estar disponível na pilha."""
        # Se o valor permanece na pilha, a operação seguinte deve funcionar
        asm = gerarAssembly(["5.0", "VAR", "3.0", "+"])
        self.assertIn("VADD.F64", asm)

    def test_variavel_declarada_uma_vez_no_data(self):
        """Mesma variável usada duas vezes não deve gerar duplicata no .data."""
        asm = gerarAssembly(["1.0", "VAR", "VAR", "2.0", "+"])
        self.assertEqual(asm.count("MEM_VAR:"), 1)

    def test_multiplas_variaveis(self):
        """Duas variáveis distintas devem gerar duas entradas no .data.
        Grava 1.0 em A e 2.0 em B, depois lê ambas e soma."""
        asm = gerarAssembly(["1.0", "A", "2.0", "B", "A", "B", "+"])
        self.assertIn("MEM_A", asm)
        self.assertIn("MEM_B", asm)

    def test_token_desconhecido_lanca_erro(self):
        """Token inválido deve lançar ValueError."""
        with self.assertRaises(ValueError):
            gerarAssembly(["5.0", "??", "3.0"])


# ---------------------------------------------------------------------------
# Testes de RES (resultado anterior)
# ---------------------------------------------------------------------------

class TesteRes(unittest.TestCase):

    def test_res0_copia_ultimo_resultado(self):
        """RES 0 deve gerar VMOV copiando o registrador do último resultado."""
        asm = gerarAssembly(["4.0", "2.0", "+", "RES", "0", "3.0", "*"])
        self.assertIn("VMOV", asm)

    def test_res_sem_argumento_lanca_erro(self):
        """RES sem número seguinte deve lançar ValueError."""
        with self.assertRaises(ValueError):
            gerarAssembly(["4.0", "2.0", "+", "RES"])

    def test_res_com_offset_invalido_lanca_erro(self):
        """RES com offset além do histórico disponível deve lançar RuntimeError."""
        with self.assertRaises(RuntimeError):
            gerarAssembly(["4.0", "2.0", "+", "RES", "5"])

    def test_res_argumento_nao_numerico_lanca_erro(self):
        """RES seguido de não-número deve lançar ValueError."""
        with self.assertRaises(ValueError):
            gerarAssembly(["4.0", "2.0", "+", "RES", "X"])

    def test_res_consome_dois_tokens(self):
        """RES deve consumir o token 'RES' e o número offset (i += 2)."""
        # Se consumir apenas um token, o '0' seria tratado como literal
        # e a multiplicação seguinte usaria o '0' em vez do resultado copiado.
        # Verificamos que não há '.double 0.0' isolado (sem contexto de variável).
        asm = gerarAssembly(["3.0", "2.0", "+", "RES", "0", "4.0", "*"])
        # O assembly deve ter VMOV (cópia do RES) e VMUL (multiplicação)
        self.assertIn("VMOV", asm)
        self.assertIn("VMUL.F64", asm)


# ---------------------------------------------------------------------------
# Testes de conversão de tipos
# ---------------------------------------------------------------------------

class TesteConversaoTipos(unittest.TestCase):

    def test_inteiro_para_float_usa_vcvt_f64_s32(self):
        """Operando inteiro passado a operação float deve gerar VCVT.F64.S32."""
        # // produz inteiro; + exige float → deve converter
        asm = gerarAssembly(["10.0", "2.0", "//", "3.0", "+"])
        self.assertIn("VCVT.F64.S32", asm)

    def test_float_para_inteiro_usa_vcvt_s32_f64(self):
        """Operando float passado a operação inteira deve gerar VCVT.S32.F64."""
        asm = gerarAssembly(["7.0", "3.0", "//"])
        self.assertIn("VCVT.S32.F64", asm)


# ---------------------------------------------------------------------------
# Testes de expressões completas (integração)
# ---------------------------------------------------------------------------

class TesteIntegracao(unittest.TestCase):

    def test_expressao_simples_soma(self):
        """Saída completa de 1.0 + 2.0 deve ser assembly válido e coerente."""
        asm = gerarAssembly(["1.0", "2.0", "+"])
        self.assertIn(".global _start", asm)
        self.assertIn("VADD.F64", asm)
        self.assertIn("B   .", asm)

    def test_expressao_com_quatro_ops(self):
        """(1+2) * (3-4) / 5 deve conter ADD, SUB, MUL e DIV."""
        asm = gerarAssembly(["1.0","2.0","+","3.0","4.0","-","*","5.0","/"])
        self.assertIn("VADD.F64", asm)
        self.assertIn("VSUB.F64", asm)
        self.assertIn("VMUL.F64", asm)
        self.assertIn("VDIV.F64", asm)

    def test_expressao_mista_float_e_inteiro(self):
        """(10//3) + 1.5 deve gerar SDIV e depois VADD."""
        asm = gerarAssembly(["10.0", "3.0", "//", "1.5", "+"])
        self.assertIn("SDIV", asm)
        self.assertIn("VADD.F64", asm)

    def test_expressao_com_variavel_e_operacao(self):
        """Gravar em VAR e depois usar VAR numa soma deve funcionar."""
        asm = gerarAssembly(["8.0", "VAR", "VAR", "2.0", "*"])
        self.assertIn("MEM_VAR", asm)
        self.assertIn("VMUL.F64", asm)

    def test_expressao_com_res_encadeado(self):
        """Dois resultados seguidos acessados por RES 0 e RES 1."""
        asm = gerarAssembly([
            "3.0", "2.0", "+",    # resultado 0 = 5.0  → entra em history[0]
            "4.0", "1.0", "-",    # resultado 1 = 3.0  → vira history[0], anterior vira history[1]
            "RES", "0",           # copia 3.0
            "RES", "1",           # copia 5.0
            "*"
        ])
        # Deve ter dois VMOV (um por RES) e um VMUL final
        vmov_count = sum(1 for l in instrucoes(asm) if l.startswith("VMOV"))
        self.assertGreaterEqual(vmov_count, 2)
        self.assertIn("VMUL.F64", asm)


# ---------------------------------------------------------------------------
# Execução
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    unittest.main(verbosity=2)