DROP TABLE IF EXISTS relatorio_qualidade;

CREATE TABLE relatorio_qualidade (
    verificacao TEXT NOT NULL,
    ocorrencias INTEGER NOT NULL,
    tratamento  TEXT NOT NULL
);

INSERT INTO relatorio_qualidade (verificacao, ocorrencias, tratamento)
SELECT
    'Linhas repetidas na base de geolocalização',
    (SELECT COUNT(*) FROM stg_geolocation)
      - (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM stg_geolocation)),
    'Base agregada para uma linha por prefixo de CEP'
UNION ALL
SELECT
    'Coordenadas fora do território brasileiro',
    (SELECT COUNT(*) FROM stg_geolocation
     WHERE NOT (CAST(geolocation_lat AS REAL) BETWEEN -33.8 AND 5.3
            AND CAST(geolocation_lng AS REAL) BETWEEN -74.0 AND -34.7)),
    'Descartadas no cálculo da coordenada média'
UNION ALL
SELECT
    'Prefixos de CEP com mais de uma grafia de cidade',
    (SELECT COUNT(*) FROM (
        SELECT geolocation_zip_code_prefix
        FROM stg_geolocation
        GROUP BY geolocation_zip_code_prefix
        HAVING COUNT(DISTINCT lower(trim(geolocation_city))) > 1)),
    'Mantida a grafia mais frequente de cada prefixo'
UNION ALL
SELECT
    'Clientes com CEP sem geolocalização',
    (SELECT COUNT(*) FROM clientes AS c
     WHERE NOT EXISTS (SELECT 1 FROM geolocalizacao AS g WHERE g.cep_prefixo = c.cep_prefixo)),
    'Mantidos; a geolocalização não é obrigatória'
UNION ALL
SELECT
    'Mesmo review_id usado em mais de um pedido',
    (SELECT COUNT(*) FROM (
        SELECT avaliacao_id FROM avaliacoes GROUP BY avaliacao_id HAVING COUNT(*) > 1)),
    'Chave primária composta (avaliacao_id, pedido_id)'
UNION ALL
SELECT
    'Produtos sem categoria',
    (SELECT COUNT(*) FROM produtos WHERE categoria IS NULL),
    'Categoria mantida nula'
UNION ALL
SELECT
    'Categorias sem tradução para o inglês',
    (SELECT COUNT(*) FROM categorias WHERE nome_ingles IS NULL),
    'Cadastradas com nome em inglês nulo'
UNION ALL
SELECT
    'Pedidos com status entregue e sem data de entrega',
    (SELECT COUNT(*) FROM pedidos WHERE status = 'delivered' AND entregue_em IS NULL),
    'Fora das análises de prazo de entrega'
UNION ALL
SELECT
    'Pedidos sem nenhum item',
    (SELECT COUNT(*) FROM pedidos AS p
     WHERE NOT EXISTS (SELECT 1 FROM itens_pedido AS i WHERE i.pedido_id = p.pedido_id)),
    'Fora das análises de faturamento'
UNION ALL
SELECT
    'Pedidos sem registro de pagamento',
    (SELECT COUNT(*) FROM pedidos AS p
     WHERE NOT EXISTS (SELECT 1 FROM pagamentos AS g WHERE g.pedido_id = p.pedido_id)),
    'Mantidos e sinalizados'
UNION ALL
SELECT
    'Pagamentos registrados com 0 parcelas',
    (SELECT COUNT(*) FROM pagamentos WHERE parcelas = 0),
    'Mantidos e sinalizados'
UNION ALL
SELECT
    'Pedidos com valor pago diferente de produtos + frete (acima de R$ 1)',
    (SELECT COUNT(*) FROM vw_pedidos
     WHERE valor_pago IS NOT NULL AND valor_produtos IS NOT NULL
       AND abs(valor_pago - (valor_produtos + valor_frete)) > 1),
    'Mantidos e sinalizados; o faturamento usa o valor dos itens';
