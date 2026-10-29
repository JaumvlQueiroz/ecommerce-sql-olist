-- Pergunta: Quanto o frete pesa no valor da compra em cada estado?
SELECT
    uf_cliente AS uf,
    COUNT(*) AS pedidos,
    ROUND(AVG(valor_produtos), 2) AS ticket_medio,
    ROUND(AVG(valor_frete), 2) AS frete_medio,
    ROUND(100.0 * SUM(valor_frete) / SUM(valor_produtos), 1) AS frete_sobre_produtos_pct
FROM vw_pedidos
WHERE conta_no_faturamento AND valor_produtos > 0
GROUP BY uf_cliente
ORDER BY frete_sobre_produtos_pct DESC;
