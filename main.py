# Trabalho RA1, Grupo 2
# Alunos: (Deixar em ordem alfabética)
# - Jorge Samuel Teixeira Jordão, JorgeSTJordao
# - Matheus Vinius Mariussi, MatheusVMariussi
# - Pedro Henrique Vargas Navarro, Navarro45
# - Nome do Aluno 4, Nome do github 4

import sys
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

def gerarAssembly(todas_linhas_tokens, codigoAssembly):
    # Gera Assembly ARMv7 a partir dos tokens
    pass

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