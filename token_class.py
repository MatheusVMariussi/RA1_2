import json

# Estrutura para representar tokens
class Token:
    def __init__(self, tipo, valor):
        self.tipo = tipo      # tipo do token (NUMBER, OP_ADD, etc)
        self.valor = valor    # texto do token

    def __repr__(self):
        return f"Token({self.tipo}, '{self.valor}')"

# Salvar tokens em arquivo JSON
def salvar_tokens(todas_linhas_tokens, nome_arquivo_fonte):

    saida = {
        "arquivo_fonte": nome_arquivo_fonte,
        "linhas": []
    }

    for i, tokens in enumerate(todas_linhas_tokens):
        linha_obj = {
            "linha": i + 1,
            "tokens": [
                {"tipo": t.tipo, "valor": t.valor}
                for t in tokens
            ]
        }
        saida["linhas"].append(linha_obj)

    with open("tokens_saida.json", "w", encoding="utf-8") as f:
        json.dump(saida, f, indent=2, ensure_ascii=False)