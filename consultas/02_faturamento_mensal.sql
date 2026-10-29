-- Pergunta: Como o faturamento evoluiu mês a mês?
WITH mensal AS (
    SELECT mes, COUNT(*) AS pedidos, SUM(valor_produtos) AS faturamento
    FROM vw_pedidos
    WHERE conta_no_faturamento
      AND mes BETWEEN '2017-01' AND '2018-08'
    GROUP BY mes
)
SELECT
    mes,
    pedidos,
    ROUND(faturamento, 2) AS faturamento,
    ROUND(faturamento / pedidos, 2) AS ticket_medio,
    ROUND(100.0 * (faturamento - LAG(faturamento) OVER janela) / LAG(faturamento) OVER janela, 1) AS variacao_pct
FROM mensal
WINDOW janela AS (ORDER BY mes)
ORDER BY mes;
