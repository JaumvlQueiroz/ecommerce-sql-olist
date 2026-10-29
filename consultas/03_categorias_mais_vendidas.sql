-- Pergunta: Quais categorias concentram o faturamento?
WITH por_categoria AS (
    SELECT
        COALESCE(pr.categoria, 'sem_categoria') AS categoria,
        COUNT(DISTINCT i.pedido_id) AS pedidos,
        SUM(i.preco) AS faturamento
    FROM itens_pedido AS i
    JOIN produtos AS pr ON pr.produto_id = i.produto_id
    JOIN pedidos AS p ON p.pedido_id = i.pedido_id
    WHERE p.status NOT IN ('canceled', 'unavailable')
    GROUP BY 1
)
SELECT
    categoria,
    pedidos,
    ROUND(faturamento, 2) AS faturamento,
    ROUND(100 * faturamento / SUM(faturamento) OVER (), 1) AS participacao_pct,
    ROUND(100 * SUM(faturamento) OVER (ORDER BY faturamento DESC) / SUM(faturamento) OVER (), 1) AS acumulado_pct
FROM por_categoria
ORDER BY faturamento DESC
LIMIT 10;
