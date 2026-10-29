-- Pergunta: Quem são os 3 maiores vendedores de cada estado?
WITH por_vendedor AS (
    SELECT
        v.uf,
        v.vendedor_id,
        COUNT(DISTINCT i.pedido_id) AS pedidos,
        SUM(i.preco) AS faturamento
    FROM itens_pedido AS i
    JOIN vendedores AS v ON v.vendedor_id = i.vendedor_id
    JOIN pedidos AS p ON p.pedido_id = i.pedido_id
    WHERE p.status NOT IN ('canceled', 'unavailable')
    GROUP BY v.uf, v.vendedor_id
),
ranking AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY uf ORDER BY faturamento DESC) AS posicao,
        SUM(faturamento) OVER (PARTITION BY uf) AS faturamento_uf
    FROM por_vendedor
)
SELECT
    uf,
    posicao,
    vendedor_id,
    pedidos,
    ROUND(faturamento, 2) AS faturamento,
    ROUND(100 * faturamento / faturamento_uf, 1) AS participacao_no_estado_pct
FROM ranking
WHERE posicao <= 3
ORDER BY faturamento_uf DESC, posicao;
