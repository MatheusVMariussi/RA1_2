from maquinaDeEstados import parseExpressao

# Testes para o analisador lexico
def testar_analisador_lexico():
    # Testes cobrindo casos válidos e inválidos

    # ----- TESTES VÁLIDOS -------

    # Teste 1: Expressão simples com adição
    tokens = []
    assert parseExpressao("(3.14 2.0 +)", tokens) == True
    assert len(tokens) == 5
    assert tokens[0].tipo == 'LPAREN'
    assert tokens[1].tipo == 'NUMBER' and tokens[1].valor == '3.14'
    assert tokens[2].tipo == 'NUMBER' and tokens[2].valor == '2.0'
    assert tokens[3].tipo == 'OP_ADD'
    assert tokens[4].tipo == 'RPAREN'
    print("Teste 1 OK: (3.14 2.0 +)")

    # Teste 2: Comando RES
    tokens = []
    assert parseExpressao("(5 RES)", tokens) == True
    assert tokens[1].tipo == 'NUMBER' and tokens[1].valor == '5'
    assert tokens[2].tipo == 'KEYWORD_RES'
    print("Teste 2 OK: (5 RES)")

    # Teste 3: Comando MEM (armazenar)
    tokens = []
    assert parseExpressao("(10.5 CONTADOR)", tokens) == True
    assert tokens[1].tipo == 'NUMBER' and tokens[1].valor == '10.5'
    assert tokens[2].tipo == 'MEM_NAME' and tokens[2].valor == 'CONTADOR'
    print("Teste 3 OK: (10.5 CONTADOR)")

    # Teste 4: Ler memória
    tokens = []
    assert parseExpressao("(CONTADOR)", tokens) == True
    assert tokens[1].tipo == 'MEM_NAME' and tokens[1].valor == 'CONTADOR'
    print("Teste 4 OK: (CONTADOR)")

    # Teste 5: Divisão inteira
    tokens = []
    assert parseExpressao("(10 3 //)", tokens) == True
    assert tokens[3].tipo == 'OP_INTDIV'
    print("Teste 5 OK: (10 3 //)")

    # Teste 6: Divisão real
    tokens = []
    assert parseExpressao("(10.0 3.0 /)", tokens) == True
    assert tokens[3].tipo == 'OP_DIV'
    print("Teste 6 OK: (10.0 3.0 /)")

    # Teste 7: Expressão aninhada
    tokens = []
    assert parseExpressao("((3.0 4.0 *) (2.0 1.0 +) /)", tokens) == True
    assert len(tokens) == 13
    print("Teste 7 OK: expressão aninhada")

    # Teste 8: Potenciação
    tokens = []
    assert parseExpressao("(2 3 ^)", tokens) == True
    assert tokens[3].tipo == 'OP_POW'
    print("Teste 8 OK: potenciação")

    # Teste 9: Módulo
    tokens = []
    assert parseExpressao("(10 3 %)", tokens) == True
    assert tokens[3].tipo == 'OP_MOD'
    print("Teste 9 OK: módulo")

    # Teste 10: Números inteiros
    tokens = []
    assert parseExpressao("(100 200 +)", tokens) == True
    assert tokens[1].valor == '100'
    print("Teste 10 OK: números inteiros")

    # Teste 11: Subtração
    tokens = []
    assert parseExpressao("(10.5 3.5 -)", tokens) == True
    assert tokens[3].tipo == 'OP_SUB'
    print("Teste 11 OK: subtração")

    # Teste 12: Multiplicação
    tokens = []
    assert parseExpressao("(4.0 2.5 *)", tokens) == True
    assert tokens[3].tipo == 'OP_MUL'
    print("Teste 12 OK: multiplicação")

    # ----- TESTES INVÁLIDOS -----

    # Teste 13: Operador inválido &
    tokens = []
    assert parseExpressao("(3.14 2.0 &)", tokens) == False
    print("Teste 13 OK: operador inválido & detectado")

    # Teste 14: Número malformado 3.14.5
    tokens = []
    assert parseExpressao("(3.14.5 2.0 +)", tokens) == False
    print("Teste 14 OK: número malformado 3.14.5 detectado")

    # Teste 15: Vírgula como separador 3,45
    tokens = []
    assert parseExpressao("(3,45 2.0 +)", tokens) == False
    print("Teste 15 OK: vírgula como separador detectada")

    # Teste 16: Minúscula em identificador
    tokens = []
    assert parseExpressao("(10.5 CONTADOr)", tokens) == False
    print("Teste 16 OK: minúscula em identificador detectada")

    # Teste 17: Número começando com ponto
    tokens = []
    assert parseExpressao("(.5 2.0 +)", tokens) == False
    print("Teste 17 OK: número começando com ponto detectado")

    # Teste 18: Letra dentro de número
    tokens = []
    assert parseExpressao("(3a4 2.0 +)", tokens) == False
    print("Teste 18 OK: letra dentro de número detectada")

    # Teste 19: Número seguido de ponto sem decimal (3.)
    tokens = []
    assert parseExpressao("(3. 2.0 +)", tokens) == False
    print("Teste 19 OK: número com ponto sem decimal detectado")

    # Teste 20: Dígito em identificador
    tokens = []
    assert parseExpressao("(10 MEM1)", tokens) == False
    print("Teste 20 OK: dígito em identificador detectado")

    print("\nTodos os testes passaram!")