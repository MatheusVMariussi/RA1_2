from token_class import Token

# Estados do DFA (cada estado é uma função)

def estadoErro(c, buffer, tokens):
    # erro lexico, limpa o buffer e sinaliza parada
    buffer.clear()
    return None

def q0_inicio(c, buffer, tokens):
    # Estado inicial
    # Decide para qual estado transitar baseado no caractere atual

    if c == '\0':       # fim / estado de aceitação
        return None

    elif c.isspace():       # ignora espaços em branco
        return (q0_inicio, True)

    elif c.isdigit():       # começo de numero: vai para estadoNumero
        buffer.append(c)
        return (estadoNumero, True)

    elif c == '.':      # numero não pode começar com ponto (.5 é inválido)
        return (estadoErro, True)

    elif c == '/':      # pode ser '/' ou '//' estadoBarra vai lidar com isso
        return (estadoBarra, True)

    elif c == '+':      # operador de add
        tokens.append(Token('OP_ADD', '+'))
        return (q0_inicio, True)

    elif c == '-':      # operador de subtração
        tokens.append(Token('OP_SUB', '-'))
        return (q0_inicio, True)

    elif c == '*':      # operador de multiplicação
        tokens.append(Token('OP_MUL', '*'))
        return (q0_inicio, True)

    elif c == '%':      # operador de módulo
        tokens.append(Token('OP_MOD', '%'))
        return (q0_inicio, True)

    elif c == '^':      # operador de potenciação
        tokens.append(Token('OP_POW', '^'))
        return (q0_inicio, True)

    elif c == '(':      # token de parentese esquerdo
        tokens.append(Token('LPAREN', '('))
        return (q0_inicio, True)

    elif c == ')':      # token de parentese direito
        tokens.append(Token('RPAREN', ')'))
        return (q0_inicio, True)

    elif c.isupper():       # começo de identificador (MEM_NAME ou RES)
        buffer.append(c)
        return (estadoIdentificador, True)

    else:       # char invalido
        return (estadoErro, True)


def estadoNumero(c, buffer, tokens):
    # estado lendo digitos da parte inteira de um número
    # Buffer tem pelo menos 1 digito

    if c.isdigit(): # se for digito, continua lendo parte inteira
        buffer.append(c)
        return (estadoNumero, True)

    elif c == '.':  # se for ponto, começa ler parte decimal
        buffer.append(c)
        return (estadoPonto, True)

    elif c.isspace() or c in '()+-*/%^\0':  # detecta fim do número = emite token NUMBER
        valor_str = ''.join(buffer)
        tokens.append(Token('NUMBER', valor_str))
        buffer.clear()
        # Reprocessa c no estado inicial
        return (q0_inicio, False)

    elif c.isalpha():   # letra dentro de número, ex "3a4", isso é invalido
        return (estadoErro, True)

    else:   # qualquer outra coisa nao esta previso, logo é erro
        return (estadoErro, True)


def estadoPonto(c, buffer, tokens):
    # acabou de ler '.'
    # logo, o buffer contém algo como ['3', '.'].
    # O próximo caractere DEVE ser um dígito.

    if c.isdigit():
        buffer.append(c)
        return (estadoDecimal, True)

    else: # "3." sem dígito depois = ERRO
        return (estadoErro, True)


def estadoDecimal(c, buffer, tokens):
    # lendo digitos dps de um ponto
    # buffer deve conter algo como ['3', '.', '1', '4'].

    if c.isdigit(): # continua lendo parte decimal
        buffer.append(c)
        return (estadoDecimal, True)

    elif c == '.':  # se achou um segundo ponto = ERRO (ex: 3.14.5)
        return (estadoErro, True)

    elif c.isspace() or c in '()+-*/%^\0':  # Fim do numero decimal = emite token NUMBER
        valor_str = ''.join(buffer)
        tokens.append(Token('NUMBER', valor_str))
        buffer.clear()
        # Reprocessa c no estado inicial
        return (q0_inicio, False)

    elif c.isalpha():  # letra dentro de numero = ERRO, ex "3.1a4"
        return (estadoErro, True)

    else:  # qualquer outra coisa nao esta previso, logo é erro
        return (estadoErro, True)


def estadoBarra(c, buffer, tokens):
    # Acabou de ler '/'
    # vamos distinguir '/' de '//'

    if c == '/':    # '//' = divisão inteira
        tokens.append(Token('OP_INTDIV', '//'))
        return (q0_inicio, True)

    else:
        # '/' sozinho = divisão real
        tokens.append(Token('OP_DIV', '/'))
        # reprocessa c no estado inicial
        return (q0_inicio, False)


def estadoIdentificador(c, buffer, tokens):
    # lendo sequencia de letras maiusculas
    # classifica como KEYWORD_RES ou MEM_NAME ao finalizar.

    if c.isupper(): # continua maiuscula, continua lendo o identificador
        buffer.append(c)
        return (estadoIdentificador, True)

    elif c.isspace() or c in ')\0': # fim do identificador
        nome = ''.join(buffer)
        buffer.clear()

        # classifica
        if nome == "RES":
            tokens.append(Token('KEYWORD_RES', 'RES'))
        else:
            tokens.append(Token('MEM_NAME', nome))

        # reprocessa c no estado inicial
        return (q0_inicio, False)

    elif c.islower():   # minuscula no identificador, "CONTADOr" = ERRO
        return (estadoErro, True)

    elif c.isdigit():   # digito no identificador: "MEM1" = ERRO
        return (estadoErro, True)

    else:   # qualquer outro char nao previsto = ERRO
        return (estadoErro, True)
    

# parser do DFA
def parseExpressao(linha, tokens):
    # percorre cada caractere da linha, chamando a função de estado atual.
    # cada função de estado retorna a próxima função de estado.

    buffer = []
    estado_atual = q0_inicio

    # '\0' para forçar emissão do último token
    entrada = linha + '\0'

    i = 0
    while i < len(entrada):
        c = entrada[i]

        resultado = estado_atual(c, buffer, tokens)

        if resultado is None:
            # Fim (aceitação) ou erro
            if estado_atual == estadoErro:
                print(f"ERRO LEXICO na posição {i}: caractere '{c}' inesperado")
                return False
            break

        proximo_estado, consumir = resultado

        if proximo_estado == estadoErro:
            print(f"ERRO LEXICO na posição {i}: caractere '{c}' inesperado")
            return False

        if consumir:
            i += 1

        estado_atual = proximo_estado

    return tokens