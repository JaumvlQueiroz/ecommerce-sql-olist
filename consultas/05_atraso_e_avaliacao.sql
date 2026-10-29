-- Pergunta: O atraso na entrega derruba a nota do cliente?
SELECT
    CASE
        WHEN dias_atraso <= -10 THEN '10 dias ou mais antes do prazo'
        WHEN dias_atraso <= 0 THEN 'Até 9 dias antes ou no prazo'
        WHEN dias_atraso <= 3 THEN '1 a 3 dias de atraso'
        WHEN dias_atraso <= 7 THEN '4 a 7 dias de atraso'
        WHEN dias_atraso <= 14 THEN '8 a 14 dias de atraso'
        ELSE 'Mais de 14 dias de atraso'
    END AS faixa,
    COUNT(*) AS pedidos,
    ROUND(AVG(nota), 2) AS nota_media,
    ROUND(100.0 * AVG(nota <= 2), 1) AS notas_1_e_2_pct,
    ROUND(100.0 * AVG(nota = 5), 1) AS notas_5_pct
FROM vw_pedidos
WHERE entregue AND nota IS NOT NULL
GROUP BY faixa
ORDER BY MIN(dias_atraso);
