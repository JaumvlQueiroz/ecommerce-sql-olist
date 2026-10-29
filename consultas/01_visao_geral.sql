-- Pergunta: Qual é o tamanho da operação no período?
SELECT
    COUNT(*) AS pedidos,
    COUNT(DISTINCT cliente_unico_id) AS clientes,
    ROUND(SUM(valor_produtos), 2) AS faturamento_produtos,
    ROUND(SUM(valor_frete), 2) AS frete_total,
    ROUND(AVG(valor_produtos), 2) AS ticket_medio,
    ROUND(AVG(qtd_itens), 2) AS itens_por_pedido,
    MIN(date(comprado_em)) AS primeira_compra,
    MAX(date(comprado_em)) AS ultima_compra
FROM vw_pedidos
WHERE conta_no_faturamento;
