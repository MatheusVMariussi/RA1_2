# Trabalho RA1, Grupo 2
# Alunos: (Deixar em ordem alfabética)
# - Matheus Vinius Mariussi, MatheusVMariussi
# - Nome do Aluno 2, Nome do github 2
# - Nome do Aluno 3, Nome do github 3
# - Nome do Aluno 4, Nome do github 4

import sys
from testesAnalisadorLexico import testar_analisador_lexico


# TODO (serão implementados pelos outros membros do grupo)

def lerArquivo(nomeArquivo):
    # Retorna: list[str] — cada string é uma linha do arquivo
    pass

def executarExpressao(tokens, resultados, memoria):
    # Avalia a expressão RPN representada por tokens
    pass

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

    if len(sys.argv) != 2:
        print("Uso: python main.py <arquivo_de_teste>")
        print("     python main.py --test  (para rodar testes)")
        sys.exit(1)

    nome_arquivo = sys.argv[1]
    print(f"Arquivo: {nome_arquivo}")
    print("(Integração completa será feita quando todas as partes estiverem prontas)")


if __name__ == "__main__":
    main()
