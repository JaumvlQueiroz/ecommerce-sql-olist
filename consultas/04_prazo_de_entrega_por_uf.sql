-- Pergunta: Em quais estados a entrega demora mais e atrasa mais?
SELECT
    uf_cliente AS uf,
    COUNT(*) AS pedidos_entregues,
    ROUND(AVG(dias_entrega), 1) AS prazo_medio_dias,
    ROUND(100.0 * AVG(dias_atraso > 0), 1) AS atrasados_pct
FROM vw_pedidos
WHERE entregue
GROUP BY uf_cliente
ORDER BY prazo_medio_dias DESC;
