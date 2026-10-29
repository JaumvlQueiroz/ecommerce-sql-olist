-- Pergunta: Quantos vendedores respondem pela maior parte do faturamento?
WITH por_vendedor AS (
    SELECT i.vendedor_id, SUM(i.preco) AS faturamento
    FROM itens_pedido AS i
    JOIN pedidos AS p ON p.pedido_id = i.pedido_id
    WHERE p.status NOT IN ('canceled', 'unavailable')
    GROUP BY i.vendedor_id
),
acumulado AS (
    SELECT
        ROW_NUMBER() OVER (ORDER BY faturamento DESC) AS posicao,
        SUM(faturamento) OVER (ORDER BY faturamento DESC ROWS UNBOUNDED PRECEDING)
            / SUM(faturamento) OVER () AS fatia_acumulada
    FROM por_vendedor
)
SELECT
    COUNT(*) AS vendedores,
    MIN(CASE WHEN fatia_acumulada >= 0.5 THEN posicao END) AS vendedores_para_50pct,
    MIN(CASE WHEN fatia_acumulada >= 0.8 THEN posicao END) AS vendedores_para_80pct,
    ROUND(100.0 * MIN(CASE WHEN fatia_acumulada >= 0.8 THEN posicao END) / COUNT(*), 1) AS vendedores_para_80pct_do_total
FROM acumulado;
