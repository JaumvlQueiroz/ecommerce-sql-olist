PRAGMA foreign_keys = ON;

DROP VIEW IF EXISTS vw_pedidos;
DROP TABLE IF EXISTS avaliacoes;
DROP TABLE IF EXISTS pagamentos;
DROP TABLE IF EXISTS itens_pedido;
DROP TABLE IF EXISTS pedidos;
DROP TABLE IF EXISTS produtos;
DROP TABLE IF EXISTS categorias;
DROP TABLE IF EXISTS vendedores;
DROP TABLE IF EXISTS clientes;
DROP TABLE IF EXISTS geolocalizacao;

CREATE TABLE geolocalizacao (
    cep_prefixo TEXT PRIMARY KEY CHECK (length(cep_prefixo) = 5),
    latitude    REAL NOT NULL CHECK (latitude BETWEEN -33.8 AND 5.3),
    longitude   REAL NOT NULL CHECK (longitude BETWEEN -74.0 AND -34.7),
    cidade      TEXT NOT NULL,
    uf          TEXT NOT NULL CHECK (length(uf) = 2)
);

CREATE TABLE clientes (
    cliente_id       TEXT PRIMARY KEY,
    cliente_unico_id TEXT NOT NULL,
    cep_prefixo      TEXT NOT NULL CHECK (length(cep_prefixo) = 5),
    cidade           TEXT NOT NULL,
    uf               TEXT NOT NULL CHECK (length(uf) = 2)
);

CREATE TABLE vendedores (
    vendedor_id TEXT PRIMARY KEY,
    cep_prefixo TEXT NOT NULL CHECK (length(cep_prefixo) = 5),
    cidade      TEXT NOT NULL,
    uf          TEXT NOT NULL CHECK (length(uf) = 2)
);

CREATE TABLE categorias (
    categoria   TEXT PRIMARY KEY,
    nome_ingles TEXT
);

CREATE TABLE produtos (
    produto_id     TEXT PRIMARY KEY,
    categoria      TEXT REFERENCES categorias (categoria),
    qtd_fotos      INTEGER CHECK (qtd_fotos >= 0),
    peso_g         REAL CHECK (peso_g >= 0),
    comprimento_cm REAL CHECK (comprimento_cm >= 0),
    altura_cm      REAL CHECK (altura_cm >= 0),
    largura_cm     REAL CHECK (largura_cm >= 0)
);

CREATE TABLE pedidos (
    pedido_id        TEXT PRIMARY KEY,
    cliente_id       TEXT NOT NULL REFERENCES clientes (cliente_id),
    status           TEXT NOT NULL CHECK (status IN (
                         'created', 'approved', 'invoiced', 'processing',
                         'shipped', 'delivered', 'canceled', 'unavailable')),
    comprado_em      TEXT NOT NULL CHECK (datetime(comprado_em) IS NOT NULL),
    aprovado_em      TEXT CHECK (aprovado_em IS NULL OR datetime(aprovado_em) IS NOT NULL),
    enviado_em       TEXT CHECK (enviado_em IS NULL OR datetime(enviado_em) IS NOT NULL),
    entregue_em      TEXT CHECK (entregue_em IS NULL OR datetime(entregue_em) IS NOT NULL),
    entrega_estimada TEXT NOT NULL CHECK (datetime(entrega_estimada) IS NOT NULL)
);

CREATE TABLE itens_pedido (
    pedido_id    TEXT NOT NULL REFERENCES pedidos (pedido_id),
    item_seq     INTEGER NOT NULL CHECK (item_seq >= 1),
    produto_id   TEXT NOT NULL REFERENCES produtos (produto_id),
    vendedor_id  TEXT NOT NULL REFERENCES vendedores (vendedor_id),
    limite_envio TEXT NOT NULL CHECK (datetime(limite_envio) IS NOT NULL),
    preco        REAL NOT NULL CHECK (preco >= 0),
    frete        REAL NOT NULL CHECK (frete >= 0),
    PRIMARY KEY (pedido_id, item_seq)
);

CREATE TABLE pagamentos (
    pedido_id TEXT NOT NULL REFERENCES pedidos (pedido_id),
    sequencia INTEGER NOT NULL CHECK (sequencia >= 1),
    tipo      TEXT NOT NULL CHECK (tipo IN ('credit_card', 'boleto', 'voucher', 'debit_card', 'not_defined')),
    parcelas  INTEGER NOT NULL CHECK (parcelas >= 0),
    valor     REAL NOT NULL CHECK (valor >= 0),
    PRIMARY KEY (pedido_id, sequencia)
);

CREATE TABLE avaliacoes (
    avaliacao_id  TEXT NOT NULL,
    pedido_id     TEXT NOT NULL REFERENCES pedidos (pedido_id),
    nota          INTEGER NOT NULL CHECK (nota BETWEEN 1 AND 5),
    titulo        TEXT,
    comentario    TEXT,
    criada_em     TEXT NOT NULL CHECK (datetime(criada_em) IS NOT NULL),
    respondida_em TEXT CHECK (respondida_em IS NULL OR datetime(respondida_em) IS NOT NULL),
    PRIMARY KEY (avaliacao_id, pedido_id)
);

CREATE INDEX idx_clientes_unico ON clientes (cliente_unico_id);
CREATE INDEX idx_clientes_uf ON clientes (uf);
CREATE INDEX idx_vendedores_uf ON vendedores (uf);
CREATE INDEX idx_produtos_categoria ON produtos (categoria);
CREATE INDEX idx_pedidos_cliente ON pedidos (cliente_id);
CREATE INDEX idx_pedidos_comprado_em ON pedidos (comprado_em);
CREATE INDEX idx_itens_produto ON itens_pedido (produto_id);
CREATE INDEX idx_itens_vendedor ON itens_pedido (vendedor_id);
CREATE INDEX idx_avaliacoes_pedido ON avaliacoes (pedido_id);
