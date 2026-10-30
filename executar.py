import csv
import sqlite3
import sys
import time
from pathlib import Path

PASTA = Path(__file__).resolve().parent
PASTA_DADOS = PASTA / "dados"
PASTA_SQL = PASTA / "sql"
PASTA_CONSULTAS = PASTA / "consultas"
PASTA_RESULTADOS = PASTA / "resultados"
PASTA_POWERBI = PASTA / "powerbi" / "dados"
BANCO = PASTA / "olist.db"

ARQUIVOS_STAGING = {
    "olist_customers_dataset.csv": "stg_customers",
    "olist_sellers_dataset.csv": "stg_sellers",
    "olist_geolocation_dataset.csv": "stg_geolocation",
    "product_category_name_translation.csv": "stg_category_translation",
    "olist_products_dataset.csv": "stg_products",
    "olist_orders_dataset.csv": "stg_orders",
    "olist_order_items_dataset.csv": "stg_order_items",
    "olist_order_payments_dataset.csv": "stg_order_payments",
    "olist_order_reviews_dataset.csv": "stg_order_reviews",
}

TABELAS_FINAIS = [
    "geolocalizacao", "clientes", "vendedores", "categorias", "produtos",
    "pedidos", "itens_pedido", "pagamentos", "avaliacoes",
]

LIMITE_LINHAS_RELATORIO = 30

TABELAS_POWERBI = {
    "dw_fato_pedidos": "fato_pedidos.csv",
    "dw_fato_itens": "fato_itens.csv",
    "dw_dim_cliente": "dim_cliente.csv",
    "dw_dim_vendedor": "dim_vendedor.csv",
    "dw_dim_produto": "dim_produto.csv",
}


def conferir_arquivos():
    faltando = [nome for nome in ARQUIVOS_STAGING if not (PASTA_DADOS / nome).exists()]
    if faltando:
        print("Arquivos não encontrados na pasta dados/:")
        for nome in faltando:
            print(f"  - {nome}")
        print("Baixe a base em https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce")
        sys.exit(1)


def executar_script(conexao, arquivo):
    conexao.executescript(arquivo.read_text(encoding="utf-8"))


def carregar_staging(conexao):
    for nome_arquivo, tabela in ARQUIVOS_STAGING.items():
        with open(PASTA_DADOS / nome_arquivo, encoding="utf-8-sig", newline="") as arquivo:
            leitor = csv.reader(arquivo)
            colunas = next(leitor)
            marcadores = ", ".join("?" for _ in colunas)
            comando = f"INSERT INTO {tabela} ({', '.join(colunas)}) VALUES ({marcadores})"
            linhas = ([valor if valor != "" else None for valor in linha] for linha in leitor)
            with conexao:
                conexao.executemany(comando, linhas)
        total = conexao.execute(f"SELECT COUNT(*) FROM {tabela}").fetchone()[0]
        print(f"  {tabela:<26} {total:>9,} linhas".replace(",", "."))


def conferir_integridade(conexao):
    violacoes = conexao.execute("PRAGMA foreign_key_check").fetchall()
    print(f"  Violações de chave estrangeira: {len(violacoes)}")
    if violacoes:
        sys.exit(1)
    for tabela in TABELAS_FINAIS:
        total = conexao.execute(f"SELECT COUNT(*) FROM {tabela}").fetchone()[0]
        print(f"  {tabela:<26} {total:>9,} linhas".replace(",", "."))


def casas_decimais(valores):
    casas = 0
    for valor in valores:
        if isinstance(valor, float):
            while casas < 2 and round(valor, casas) != valor:
                casas += 1
    return casas


def formatar_valor(valor, casas):
    if valor is None:
        return ""
    if isinstance(valor, (int, float)):
        return f"{valor:,.{casas}f}".replace(",", "X").replace(".", ",").replace("X", ".")
    return str(valor).replace("|", "\\|")


def tabela_markdown(colunas, linhas):
    casas = [casas_decimais(linha[i] for linha in linhas) for i in range(len(colunas))]
    cabecalho = "| " + " | ".join(colunas) + " |"
    separador = "| " + " | ".join("---" for _ in colunas) + " |"
    corpo = ["| " + " | ".join(formatar_valor(v, c) for v, c in zip(linha, casas)) + " |" for linha in linhas]
    return "\n".join([cabecalho, separador, *corpo])


def pergunta_da_consulta(texto):
    for linha in texto.splitlines():
        if linha.startswith("-- Pergunta:"):
            return linha.removeprefix("-- Pergunta:").strip()
    return ""


def relatorio_qualidade(conexao):
    cursor = conexao.execute("SELECT verificacao, ocorrencias, tratamento FROM relatorio_qualidade")
    colunas = [d[0] for d in cursor.description]
    linhas = cursor.fetchall()
    for verificacao, ocorrencias, _ in linhas:
        print(f"  {ocorrencias:>7,}  {verificacao}".replace(",", "."))
    return "## Relatório de qualidade dos dados\n\n" + tabela_markdown(colunas, linhas)


def executar_consultas(conexao, secao_qualidade):
    PASTA_RESULTADOS.mkdir(exist_ok=True)
    secoes = [secao_qualidade]

    for arquivo in sorted(PASTA_CONSULTAS.glob("*.sql")):
        texto = arquivo.read_text(encoding="utf-8")
        inicio = time.perf_counter()
        cursor = conexao.execute(texto)
        colunas = [d[0] for d in cursor.description]
        linhas = cursor.fetchall()
        duracao = time.perf_counter() - inicio

        with open(PASTA_RESULTADOS / f"{arquivo.stem}.csv", "w", encoding="utf-8", newline="") as saida:
            escritor = csv.writer(saida)
            escritor.writerow(colunas)
            escritor.writerows(linhas)

        pergunta = pergunta_da_consulta(texto)
        exibidas = linhas[:LIMITE_LINHAS_RELATORIO]
        secao = f"## {pergunta}\n\nConsulta: [`consultas/{arquivo.name}`](../consultas/{arquivo.name})\n\n"
        secao += tabela_markdown(colunas, exibidas)
        if len(linhas) > len(exibidas):
            secao += f"\n\nMostrando {len(exibidas)} de {len(linhas)} linhas. Resultado completo em [`{arquivo.stem}.csv`]({arquivo.stem}.csv)."
        secoes.append(secao)
        print(f"  {arquivo.name:<38} {len(linhas):>4} linhas  {duracao:.2f}s")

    relatorio = "# Resultados\n\nArquivo gerado automaticamente por `executar.py`.\n\n" + "\n\n".join(secoes) + "\n"
    (PASTA_RESULTADOS / "RESULTADOS.md").write_text(relatorio, encoding="utf-8")


def valor_brasileiro(valor):
    if valor is None:
        return ""
    if isinstance(valor, float):
        return repr(valor).replace(".", ",")
    return valor


def exportar_powerbi(conexao):
    PASTA_POWERBI.mkdir(parents=True, exist_ok=True)
    for visao, nome_arquivo in TABELAS_POWERBI.items():
        cursor = conexao.execute(f"SELECT * FROM {visao}")
        colunas = [d[0] for d in cursor.description]
        with open(PASTA_POWERBI / nome_arquivo, "w", encoding="utf-8-sig", newline="") as saida:
            escritor = csv.writer(saida, delimiter=";")
            escritor.writerow(colunas)
            total = 0
            for linha in cursor:
                escritor.writerow(valor_brasileiro(v) for v in linha)
                total += 1
        print(f"  {nome_arquivo:<26} {total:>9,} linhas".replace(",", "."))


def main():
    inicio = time.perf_counter()
    conferir_arquivos()
    try:
        BANCO.unlink(missing_ok=True)
    except PermissionError:
        print(f"Não foi possível recriar {BANCO.name}. Feche o banco no DBeaver ou em outro programa e rode de novo.")
        sys.exit(1)

    conexao = sqlite3.connect(BANCO)
    conexao.execute("PRAGMA foreign_keys = ON")

    print("1. Carregando os CSVs nas tabelas de staging")
    executar_script(conexao, PASTA_SQL / "01_staging.sql")
    carregar_staging(conexao)

    print("2. Criando o modelo relacional e transformando os dados")
    executar_script(conexao, PASTA_SQL / "02_modelo.sql")
    executar_script(conexao, PASTA_SQL / "03_transformacao.sql")
    executar_script(conexao, PASTA_SQL / "04_views.sql")
    conferir_integridade(conexao)

    print("3. Verificando a qualidade dos dados")
    executar_script(conexao, PASTA_SQL / "05_qualidade.sql")
    secao_qualidade = relatorio_qualidade(conexao)

    print("4. Executando as consultas de negócio")
    executar_consultas(conexao, secao_qualidade)

    print("5. Exportando o modelo dimensional para o Power BI")
    executar_script(conexao, PASTA_SQL / "07_modelo_dimensional.sql")
    exportar_powerbi(conexao)

    executar_script(conexao, PASTA_SQL / "06_limpeza.sql")
    conexao.execute("VACUUM")
    conexao.close()
    print(f"\nBanco criado em {BANCO.name} em {time.perf_counter() - inicio:.1f}s.")
    print("Resultados em resultados/RESULTADOS.md")
    print("Arquivos do Power BI em powerbi/dados/")


if __name__ == "__main__":
    main()
