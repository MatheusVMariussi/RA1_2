# Trabalho RA1, Grupo 2
# Alunos: (Deixar em ordem alfabética)
# - Jorge Samuel Teixeira Jordão, JorgeSTJordao
# - Matheus Vinius Mariussi, MatheusVMariussi
# - Nome do Aluno 3, Nome do github 3
# - Nome do Aluno 4, Nome do github 4

import sys
from testesAnalisadorLexico import testar_analisador_lexico
from testesExecutarExpressao import testar_executar_expressao
from maquinaDeEstados import parseExpressao

# TODO (serão implementados pelos outros membros do grupo)

def lerArquivo(nomeArquivo):
    # Retorna: list[str] — cada string é uma linha do arquivo
    pass

def gerarAssembly(todas_linhas_tokens, codigoAssembly):
    # Gera Assembly ARMv7 a partir dos tokens
    pass

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