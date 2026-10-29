-- Pergunta: Quantos clientes voltam a comprar?
WITH compras AS (
    SELECT cliente_unico_id, COUNT(*) AS pedidos
    FROM vw_pedidos
    WHERE conta_no_faturamento
    GROUP BY cliente_unico_id
)
SELECT
    CASE
        WHEN pedidos = 1 THEN '1 pedido'
        WHEN pedidos = 2 THEN '2 pedidos'
        ELSE '3 pedidos ou mais'
    END AS faixa,
    COUNT(*) AS clientes,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS clientes_pct
FROM compras
GROUP BY faixa
ORDER BY MIN(pedidos);
