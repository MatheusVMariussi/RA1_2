
from maquinaDeEstados import parseExpressao

def executarExpressao(tokens_lista, resultados, memoria):
    # Avalia a expressão RPN representada por tokens

    for tokens in tokens_lista:
        pilha = []
        for token in tokens:
            if token.tipo == 'NUMBER':
                pilha.append(float(token.valor))

            elif token.tipo == 'KEYWORD_RES':
                # (N RES) : Retorna o resultado da expressão N linhas anteriores
                # N deve estar no topo da pilha
                n = int(pilha.pop())
                if n < 0:
                    raise ValueError(f"Índice RES negativo: {n}")
                if n == 0 or n > len(resultados):
                    raise ValueError(f"Índice RES inválido: {n} (apenas {len(resultados)} resultados disponíveis)")
                # N=1 significa o resultado mais recente, N=2 o penúltimo, etc.
                resultado_anterior = resultados[-n]
                pilha.append(resultado_anterior)


            elif token.tipo in ('OP_ADD', 'OP_SUB', 'OP_MUL', 'OP_DIV',
                                'OP_INTDIV', 'OP_MOD', 'OP_POW'):

                if len(pilha) < 2:
                    raise ValueError("Operandos insuficientes.")

                b = pilha.pop()
                a = pilha.pop()

                if token.tipo == 'OP_ADD':
                    pilha.append(a + b)
                elif token.tipo == 'OP_SUB':
                    pilha.append(a - b)
                elif token.tipo == 'OP_MUL':
                    pilha.append(a * b)
                elif token.tipo == 'OP_DIV':
                    if b == 0:
                        raise ValueError("Divisão por zero.")
                    pilha.append(a / b)
                elif token.tipo == 'OP_INTDIV':
                    if b == 0:
                        raise ValueError("Divisão inteira por zero.")
                    pilha.append(int(a // b))
                elif token.tipo == 'OP_MOD':
                    if b == 0:
                        raise ValueError("Módulo por zero.")
                    pilha.append(int(a % b))
                elif token.tipo == 'OP_POW':
                    pilha.append(a ** b)
            elif token.tipo == 'MEM_NAME':
                nome = token.valor
                if pilha:
                    memoria = pilha.pop()
                    pilha.append(memoria)
                elif memoria != None:
                    pilha.append(memoria)
                else:
                    pilha.append(0.0)
        resultado = pilha[-1] if pilha else None
        resultados.append(resultado)

    return resultados

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
