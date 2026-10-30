DROP VIEW IF EXISTS dw_dim_regiao;
DROP VIEW IF EXISTS dw_dim_cliente;
DROP VIEW IF EXISTS dw_dim_vendedor;
DROP VIEW IF EXISTS dw_dim_produto;
DROP VIEW IF EXISTS dw_fato_pedidos;
DROP VIEW IF EXISTS dw_fato_itens;

CREATE VIEW dw_dim_regiao AS
WITH ufs (uf, regiao) AS (
    VALUES
        ('AC', 'Norte'), ('AP', 'Norte'), ('AM', 'Norte'), ('PA', 'Norte'),
        ('RO', 'Norte'), ('RR', 'Norte'), ('TO', 'Norte'),
        ('AL', 'Nordeste'), ('BA', 'Nordeste'), ('CE', 'Nordeste'), ('MA', 'Nordeste'),
        ('PB', 'Nordeste'), ('PE', 'Nordeste'), ('PI', 'Nordeste'), ('RN', 'Nordeste'),
        ('SE', 'Nordeste'),
        ('DF', 'Centro-Oeste'), ('GO', 'Centro-Oeste'), ('MT', 'Centro-Oeste'),
        ('MS', 'Centro-Oeste'),
        ('ES', 'Sudeste'), ('MG', 'Sudeste'), ('RJ', 'Sudeste'), ('SP', 'Sudeste'),
        ('PR', 'Sul'), ('RS', 'Sul'), ('SC', 'Sul')
)
SELECT uf, regiao FROM ufs;

CREATE VIEW dw_dim_cliente AS
SELECT
    c.cliente_id,
    c.cliente_unico_id,
    c.cidade,
    c.uf,
    r.regiao
FROM clientes AS c
LEFT JOIN dw_dim_regiao AS r ON r.uf = c.uf;

CREATE VIEW dw_dim_vendedor AS
SELECT
    v.vendedor_id,
    v.cidade,
    v.uf,
    r.regiao
FROM vendedores AS v
LEFT JOIN dw_dim_regiao AS r ON r.uf = v.uf;

CREATE VIEW dw_dim_produto AS
SELECT
    produto_id,
    COALESCE(replace(categoria, '_', ' '), 'sem categoria') AS categoria,
    peso_g
FROM produtos;

CREATE VIEW dw_fato_pedidos AS
SELECT
    p.pedido_id,
    p.cliente_id,
    date(v.comprado_em) AS data_compra,
    v.status,
    v.qtd_itens,
    ROUND(v.valor_produtos, 2) AS valor_produtos,
    ROUND(v.valor_frete, 2) AS valor_frete,
    v.entregue,
    CASE WHEN v.entregue THEN ROUND(v.dias_entrega, 1) END AS dias_entrega,
    CASE WHEN v.entregue THEN CAST(v.dias_atraso AS INTEGER) END AS dias_atraso,
    CASE WHEN v.entregue THEN v.dias_atraso > 0 END AS atrasado,
    CASE
        WHEN NOT v.entregue THEN NULL
        WHEN v.dias_atraso <= -10 THEN '10 dias ou mais antes do prazo'
        WHEN v.dias_atraso <= 0 THEN 'Até 9 dias antes ou no prazo'
        WHEN v.dias_atraso <= 3 THEN '1 a 3 dias de atraso'
        WHEN v.dias_atraso <= 7 THEN '4 a 7 dias de atraso'
        WHEN v.dias_atraso <= 14 THEN '8 a 14 dias de atraso'
        ELSE 'Mais de 14 dias de atraso'
    END AS faixa_atraso,
    CASE
        WHEN NOT v.entregue THEN NULL
        WHEN v.dias_atraso <= -10 THEN 1
        WHEN v.dias_atraso <= 0 THEN 2
        WHEN v.dias_atraso <= 3 THEN 3
        WHEN v.dias_atraso <= 7 THEN 4
        WHEN v.dias_atraso <= 14 THEN 5
        ELSE 6
    END AS ordem_faixa_atraso,
    v.nota
FROM vw_pedidos AS v
JOIN pedidos AS p ON p.pedido_id = v.pedido_id
WHERE v.conta_no_faturamento;

CREATE VIEW dw_fato_itens AS
SELECT
    i.pedido_id,
    i.item_seq,
    p.cliente_id,
    i.produto_id,
    i.vendedor_id,
    date(p.comprado_em) AS data_compra,
    i.preco,
    i.frete
FROM itens_pedido AS i
JOIN pedidos AS p ON p.pedido_id = i.pedido_id
WHERE p.status NOT IN ('canceled', 'unavailable');
