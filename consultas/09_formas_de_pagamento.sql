-- Pergunta: Como os clientes pagam?
SELECT
    tipo,
    COUNT(DISTINCT pedido_id) AS pedidos,
    ROUND(100.0 * COUNT(DISTINCT pedido_id) / (SELECT COUNT(DISTINCT pedido_id) FROM pagamentos), 1) AS pedidos_pct,
    ROUND(SUM(valor), 2) AS valor_total,
    ROUND(AVG(valor), 2) AS valor_medio,
    ROUND(AVG(parcelas), 1) AS parcelas_media
FROM pagamentos
WHERE tipo <> 'not_defined'
GROUP BY tipo
ORDER BY pedidos DESC;
