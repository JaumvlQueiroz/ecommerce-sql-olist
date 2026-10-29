PRAGMA foreign_keys = ON;

INSERT INTO geolocalizacao (cep_prefixo, latitude, longitude, cidade, uf)
WITH validas AS (
    SELECT
        geolocation_zip_code_prefix AS cep_prefixo,
        CAST(geolocation_lat AS REAL) AS latitude,
        CAST(geolocation_lng AS REAL) AS longitude,
        lower(trim(geolocation_city)) AS cidade,
        upper(trim(geolocation_state)) AS uf
    FROM stg_geolocation
    WHERE CAST(geolocation_lat AS REAL) BETWEEN -33.8 AND 5.3
      AND CAST(geolocation_lng AS REAL) BETWEEN -74.0 AND -34.7
),
grafias AS (
    SELECT
        cep_prefixo,
        cidade,
        uf,
        ROW_NUMBER() OVER (PARTITION BY cep_prefixo ORDER BY COUNT(*) DESC, cidade) AS ordem
    FROM validas
    GROUP BY cep_prefixo, cidade, uf
),
coordenadas AS (
    SELECT cep_prefixo, AVG(latitude) AS latitude, AVG(longitude) AS longitude
    FROM validas
    GROUP BY cep_prefixo
)
SELECT c.cep_prefixo, c.latitude, c.longitude, g.cidade, g.uf
FROM coordenadas AS c
JOIN grafias AS g ON g.cep_prefixo = c.cep_prefixo AND g.ordem = 1;

INSERT INTO clientes (cliente_id, cliente_unico_id, cep_prefixo, cidade, uf)
SELECT
    customer_id,
    customer_unique_id,
    customer_zip_code_prefix,
    lower(trim(customer_city)),
    upper(trim(customer_state))
FROM stg_customers;

INSERT INTO vendedores (vendedor_id, cep_prefixo, cidade, uf)
SELECT
    seller_id,
    seller_zip_code_prefix,
    lower(trim(seller_city)),
    upper(trim(seller_state))
FROM stg_sellers;

INSERT INTO categorias (categoria, nome_ingles)
SELECT trim(product_category_name), trim(product_category_name_english)
FROM stg_category_translation;

INSERT OR IGNORE INTO categorias (categoria, nome_ingles)
SELECT DISTINCT trim(product_category_name), NULL
FROM stg_products
WHERE product_category_name IS NOT NULL;

INSERT INTO produtos (produto_id, categoria, qtd_fotos, peso_g, comprimento_cm, altura_cm, largura_cm)
SELECT
    product_id,
    trim(product_category_name),
    CAST(product_photos_qty AS INTEGER),
    CAST(product_weight_g AS REAL),
    CAST(product_length_cm AS REAL),
    CAST(product_height_cm AS REAL),
    CAST(product_width_cm AS REAL)
FROM stg_products;

INSERT INTO pedidos (pedido_id, cliente_id, status, comprado_em, aprovado_em, enviado_em, entregue_em, entrega_estimada)
SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date
FROM stg_orders;

INSERT INTO itens_pedido (pedido_id, item_seq, produto_id, vendedor_id, limite_envio, preco, frete)
SELECT
    order_id,
    CAST(order_item_id AS INTEGER),
    product_id,
    seller_id,
    shipping_limit_date,
    CAST(price AS REAL),
    CAST(freight_value AS REAL)
FROM stg_order_items;

INSERT INTO pagamentos (pedido_id, sequencia, tipo, parcelas, valor)
SELECT
    order_id,
    CAST(payment_sequential AS INTEGER),
    payment_type,
    CAST(payment_installments AS INTEGER),
    CAST(payment_value AS REAL)
FROM stg_order_payments;

INSERT INTO avaliacoes (avaliacao_id, pedido_id, nota, titulo, comentario, criada_em, respondida_em)
SELECT
    review_id,
    order_id,
    CAST(review_score AS INTEGER),
    review_comment_title,
    review_comment_message,
    review_creation_date,
    review_answer_timestamp
FROM stg_order_reviews;
