
from maquinaDeEstados import parseExpressao

def executarExpressao(tokens_lista, resultados, memoria):
    # Avalia a expressão RPN representada por tokens
    pilha = []
    resultado = None
    for tokens in tokens_lista:
        for token in tokens:
            if token.tipo == 'NUMBER':
                pilha.append(float(token.valor))
            elif token.tipo == 'MEM':
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

# Funções de teste para execução de expressões e comandos especiais
def testar_executar_expressao():

    def parse(expr):
        tokens = []
        assert parseExpressao(expr, tokens)
        return tokens

    memoria = {}
    resultados = []

    # Teste 1: Soma simples
    tokens = parse("(3.0 2.0 +)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 5.0
    print("Teste executarExpressao 1 OK: soma simples")

    # Teste 2: Potenciação
    tokens = parse("(2 3 ^)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 8.0
    print("Teste executarExpressao 2 OK: potenciação")

    # Teste 3: Divisão inteira e resto
    tokens = parse("(10 3 //)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 3
    tokens = parse("(10 3 %)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 1
    print("Teste executarExpressao 3 OK: divisão inteira e resto")


    # Teste 4: Armazenar e ler memória (válido)
    # Primeiro armazena, depois lê
    tokens = parse("(10.5 CONTADOR)")
    executarExpressao(tokens, resultados, memoria)
    assert memoria["CONTADOR"] == 10.5
    tokens = parse("(CONTADOR)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 10.5
    print("Teste executarExpressao 4 OK: memória criada e lida")

    # Teste 5: Sobrescrever variável
    tokens = parse("(20 CONTADOR)")
    executarExpressao(tokens, resultados, memoria)
    assert memoria["CONTADOR"] == 20.0
    tokens = parse("(CONTADOR)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 20.0
    print("Teste executarExpressao 5 OK: sobrescrita de variável")

    # Teste 6: Múltiplas variáveis
    tokens = parse("(7 X)")
    executarExpressao(tokens, resultados, memoria)
    tokens = parse("(3 Y)")
    executarExpressao(tokens, resultados, memoria)
    assert memoria["X"] == 7.0
    assert memoria["Y"] == 3.0
    tokens = parse("(X)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 7.0
    tokens = parse("(Y)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 3.0
    print("Teste executarExpressao 6 OK: múltiplas variáveis")

    # Teste 5: Histórico de resultados
    tokens = parse("(5 RES)")
    executarExpressao(tokens, resultados, memoria)
    assert resultados[-1] == 5.0
    print("Teste executarExpressao 5 OK: histórico de resultados")

    # Teste 7: Expressão aninhada — (3.0 * 4.0) / (2.0 + 1.0) = 12.0 / 3.0 = 4.0
    tokens = parse("((3.0 4.0 *) (2.0 1.0 +) /)")
    res = executarExpressao(tokens, resultados, memoria)
    assert res == 4.0
    print("Teste executarExpressao 7 OK: expressão aninhada")

    print("\nTodos os testes de executarExpressao passaram!")

if __name__ == "__main__":
    testar_executar_expressao()
