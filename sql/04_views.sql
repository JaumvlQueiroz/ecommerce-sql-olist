DROP VIEW IF EXISTS vw_pedidos;

CREATE VIEW vw_pedidos AS
WITH itens AS (
    SELECT
        pedido_id,
        COUNT(*) AS qtd_itens,
        SUM(preco) AS valor_produtos,
        SUM(frete) AS valor_frete
    FROM itens_pedido
    GROUP BY pedido_id
),
pagos AS (
    SELECT pedido_id, SUM(valor) AS valor_pago
    FROM pagamentos
    GROUP BY pedido_id
),
notas AS (
    SELECT pedido_id, AVG(nota) AS nota
    FROM avaliacoes
    GROUP BY pedido_id
)
SELECT
    p.pedido_id,
    p.status,
    c.cliente_unico_id,
    c.uf AS uf_cliente,
    p.comprado_em,
    strftime('%Y-%m', p.comprado_em) AS mes,
    i.qtd_itens,
    i.valor_produtos,
    i.valor_frete,
    pg.valor_pago,
    n.nota,
    julianday(p.entregue_em) - julianday(p.comprado_em) AS dias_entrega,
    julianday(date(p.entregue_em)) - julianday(date(p.entrega_estimada)) AS dias_atraso,
    p.status NOT IN ('canceled', 'unavailable') AND i.pedido_id IS NOT NULL AS conta_no_faturamento,
    p.status = 'delivered' AND p.entregue_em IS NOT NULL AS entregue
FROM pedidos AS p
JOIN clientes AS c ON c.cliente_id = p.cliente_id
LEFT JOIN itens AS i ON i.pedido_id = p.pedido_id
LEFT JOIN pagos AS pg ON pg.pedido_id = p.pedido_id
LEFT JOIN notas AS n ON n.pedido_id = p.pedido_id;
