# Resultados

Arquivo gerado automaticamente por `executar.py`.

## Relatório de qualidade dos dados

| verificacao | ocorrencias | tratamento |
| --- | --- | --- |
| Linhas repetidas na base de geolocalização | 261.831 | Base agregada para uma linha por prefixo de CEP |
| Coordenadas fora do território brasileiro | 42 | Descartadas no cálculo da coordenada média |
| Prefixos de CEP com mais de uma grafia de cidade | 8.555 | Mantida a grafia mais frequente de cada prefixo |
| Clientes com CEP sem geolocalização | 279 | Mantidos; a geolocalização não é obrigatória |
| Mesmo review_id usado em mais de um pedido | 789 | Chave primária composta (avaliacao_id, pedido_id) |
| Produtos sem categoria | 610 | Categoria mantida nula |
| Categorias sem tradução para o inglês | 2 | Cadastradas com nome em inglês nulo |
| Pedidos com status entregue e sem data de entrega | 8 | Fora das análises de prazo de entrega |
| Pedidos sem nenhum item | 775 | Fora das análises de faturamento |
| Pedidos sem registro de pagamento | 1 | Mantidos e sinalizados |
| Pagamentos registrados com 0 parcelas | 2 | Mantidos e sinalizados |
| Pedidos com valor pago diferente de produtos + frete (acima de R$ 1) | 249 | Mantidos e sinalizados; o faturamento usa o valor dos itens |

## Qual é o tamanho da operação no período?

Consulta: [`consultas/01_visao_geral.sql`](../consultas/01_visao_geral.sql)

| pedidos | clientes | faturamento_produtos | frete_total | ticket_medio | itens_por_pedido | primeira_compra | ultima_compra |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 98.199 | 94.983 | 13.494.400,74 | 2.241.126,29 | 137,42 | 1,14 | 2016-09-04 | 2018-09-03 |

## Como o faturamento evoluiu mês a mês?

Consulta: [`consultas/02_faturamento_mensal.sql`](../consultas/02_faturamento_mensal.sql)

| mes | pedidos | faturamento | ticket_medio | variacao_pct |
| --- | --- | --- | --- | --- |
| 2017-01 | 787 | 120.098,27 | 152,60 |  |
| 2017-02 | 1.718 | 244.959,35 | 142,58 | 104,0 |
| 2017-03 | 2.617 | 368.341,32 | 140,75 | 50,4 |
| 2017-04 | 2.377 | 353.842,98 | 148,86 | -3,9 |
| 2017-05 | 3.640 | 503.159,19 | 138,23 | 42,2 |
| 2017-06 | 3.205 | 429.916,61 | 134,14 | -14,6 |
| 2017-07 | 3.946 | 492.287,30 | 124,76 | 14,5 |
| 2017-08 | 4.272 | 568.245,79 | 133,02 | 15,4 |
| 2017-09 | 4.227 | 621.415,91 | 147,01 | 9,4 |
| 2017-10 | 4.547 | 660.179,62 | 145,19 | 6,2 |
| 2017-11 | 7.421 | 1.003.862,14 | 135,27 | 52,1 |
| 2017-12 | 5.618 | 742.183,79 | 132,11 | -26,1 |
| 2018-01 | 7.187 | 945.456,29 | 131,55 | 27,4 |
| 2018-02 | 6.624 | 837.895,43 | 126,49 | -11,4 |
| 2018-03 | 7.168 | 981.051,06 | 136,87 | 17,1 |
| 2018-04 | 6.919 | 993.592,98 | 143,60 | 1,3 |
| 2018-05 | 6.833 | 992.871,75 | 145,31 | -0,1 |
| 2018-06 | 6.145 | 863.265,53 | 140,48 | -13,1 |
| 2018-07 | 6.233 | 878.044,27 | 140,87 | 1,7 |
| 2018-08 | 6.421 | 848.860,10 | 132,20 | -3,3 |

## Quais categorias concentram o faturamento?

Consulta: [`consultas/03_categorias_mais_vendidas.sql`](../consultas/03_categorias_mais_vendidas.sql)

| categoria | pedidos | faturamento | participacao_pct | acumulado_pct |
| --- | --- | --- | --- | --- |
| beleza_saude | 8.800 | 1.255.695,13 | 9,3 | 9,3 |
| relogios_presentes | 5.604 | 1.198.185,21 | 8,9 | 18,2 |
| cama_mesa_banho | 9.399 | 1.035.964,06 | 7,7 | 25,9 |
| esporte_lazer | 7.673 | 979.740,92 | 7,3 | 33,1 |
| informatica_acessorios | 6.654 | 904.322,02 | 6,7 | 39,8 |
| moveis_decoracao | 6.425 | 727.465,05 | 5,4 | 45,2 |
| utilidades_domesticas | 5.847 | 626.825,80 | 4,6 | 49,9 |
| cool_stuff | 3.616 | 620.770,49 | 4,6 | 54,5 |
| automotivo | 3.872 | 586.585,73 | 4,3 | 58,8 |
| ferramentas_jardim | 3.505 | 481.009,94 | 3,6 | 62,4 |

## Em quais estados a entrega demora mais e atrasa mais?

Consulta: [`consultas/04_prazo_de_entrega_por_uf.sql`](../consultas/04_prazo_de_entrega_por_uf.sql)

| uf | pedidos_entregues | prazo_medio_dias | atrasados_pct |
| --- | --- | --- | --- |
| RR | 41 | 29,4 | 12,2 |
| AP | 67 | 27,2 | 3,0 |
| AM | 145 | 26,4 | 2,8 |
| AL | 397 | 24,5 | 21,4 |
| PA | 946 | 23,8 | 11,2 |
| MA | 717 | 21,6 | 17,4 |
| SE | 335 | 21,5 | 15,2 |
| CE | 1.279 | 21,3 | 13,8 |
| AC | 80 | 21,0 | 3,8 |
| PB | 517 | 20,4 | 10,4 |
| PI | 476 | 19,5 | 13,9 |
| RO | 243 | 19,4 | 2,9 |
| BA | 3.256 | 19,3 | 12,2 |
| RN | 474 | 19,3 | 9,3 |
| PE | 1.593 | 18,4 | 9,6 |
| MT | 886 | 18,1 | 6,0 |
| TO | 274 | 17,7 | 9,9 |
| ES | 1.995 | 15,8 | 10,7 |
| GO | 1.957 | 15,6 | 6,5 |
| MS | 701 | 15,6 | 9,7 |
| RJ | 12.350 | 15,3 | 12,1 |
| RS | 5.344 | 15,3 | 6,1 |
| SC | 3.546 | 15,0 | 8,2 |
| DF | 2.080 | 13,0 | 5,7 |
| MG | 11.354 | 12,0 | 4,6 |
| PR | 4.923 | 12,0 | 4,0 |
| SP | 40.494 | 8,8 | 4,5 |

## O atraso na entrega derruba a nota do cliente?

Consulta: [`consultas/05_atraso_e_avaliacao.sql`](../consultas/05_atraso_e_avaliacao.sql)

| faixa | pedidos | nota_media | notas_1_e_2_pct | notas_5_pct |
| --- | --- | --- | --- | --- |
| 10 dias ou mais antes do prazo | 61.523 | 4,32 | 8,9 | 63,9 |
| Até 9 dias antes ou no prazo | 27.920 | 4,22 | 10,1 | 58,5 |
| 1 a 3 dias de atraso | 1.852 | 3,29 | 32,2 | 33,2 |
| 4 a 7 dias de atraso | 1.748 | 2,11 | 67,6 | 14,1 |
| 8 a 14 dias de atraso | 1.446 | 1,67 | 80,1 | 6,8 |
| Mais de 14 dias de atraso | 1.335 | 1,73 | 78,2 | 7,2 |

## Quantos clientes voltam a comprar?

Consulta: [`consultas/06_recompra.sql`](../consultas/06_recompra.sql)

| faixa | clientes | clientes_pct |
| --- | --- | --- |
| 1 pedido | 92.096 | 96,96 |
| 2 pedidos | 2.651 | 2,79 |
| 3 pedidos ou mais | 236 | 0,25 |

## Quem são os 3 maiores vendedores de cada estado?

Consulta: [`consultas/07_top_vendedores_por_uf.sql`](../consultas/07_top_vendedores_por_uf.sql)

| uf | posicao | vendedor_id | pedidos | faturamento | participacao_no_estado_pct |
| --- | --- | --- | --- | --- | --- |
| SP | 1 | 4869f7a5dfa277a7dca6462dcf3b52b2 | 1.131 | 229.237,63 | 2,6 |
| SP | 2 | 4a3ca9315b744ce9f8e9374361493884 | 1.804 | 200.326,12 | 2,3 |
| SP | 3 | fa1c13f2614d7b5c4749cbc52fecda94 | 584 | 192.842,13 | 2,2 |
| PR | 1 | ccc4bbb5f32a6ab2b7066a4130f114e3 | 187 | 74.004,62 | 5,9 |
| PR | 2 | 522620dcb18a6b31cd7bdf73665113a9 | 174 | 57.168,49 | 4,5 |
| PR | 3 | 77530e9772f57a62c906e1c21538ab82 | 319 | 46.470,50 | 3,7 |
| MG | 1 | a1043bafd471dff536d0c462352beb48 | 715 | 101.483,16 | 10,1 |
| MG | 2 | 25c5c91f63607446a97b143d2d535d31 | 158 | 54.679,22 | 5,5 |
| MG | 3 | 7299e27ed73d2ad986de7f7c77d919fa | 337 | 34.225,43 | 3,4 |
| RJ | 1 | 46dc3b2cc0980fb8ec44634e21d2718e | 518 | 127.161,22 | 15,2 |
| RJ | 2 | 620c87c171fb2a6dd6e8bb4dec959fc6 | 732 | 113.659,40 | 13,6 |
| RJ | 3 | edb1ef5e36e0c8cd84eb3c9b003e486d | 166 | 79.284,55 | 9,5 |
| SC | 1 | 04308b1ee57b6625f47df1d56f00eedf | 94 | 60.130,60 | 9,6 |
| SC | 2 | eeb6de78f79159600292e314a77cbd18 | 83 | 43.739,84 | 7,0 |
| SC | 3 | 712e6ed8aa4aa1fa65dab41fed5737e4 | 79 | 39.815,00 | 6,4 |
| RS | 1 | 87142160b41353c4e5fca2360caf6f92 | 305 | 31.095,98 | 8,2 |
| RS | 2 | b32be1695eb7ec5f10f72d9610a12527 | 45 | 26.874,00 | 7,1 |
| RS | 3 | 12b9676b00f60f3b700e83af21824c0e | 134 | 26.575,00 | 7,0 |
| BA | 1 | 53243585a1d6dc2643021fd1853d8905 | 358 | 222.776,05 | 78,1 |
| BA | 2 | c72de06d72748d1a0dfb2125be43ba63 | 21 | 17.522,00 | 6,1 |
| BA | 3 | 75d34ebb1bd0bd7dde40dd507b8169c3 | 61 | 14.928,29 | 5,2 |
| DF | 1 | 44073f8b7e41514de3b7815dd0237f4f | 144 | 18.729,64 | 19,3 |
| DF | 2 | f3b80352b986ab4d1057a4b724be19d0 | 87 | 10.505,10 | 10,8 |
| DF | 3 | 3c487ae8f8d7542beff5788e2e0aea83 | 30 | 9.385,70 | 9,7 |
| PE | 1 | de722cd6dad950a92b7d4f82673f8833 | 339 | 55.426,10 | 60,6 |
| PE | 2 | 40db9e9aa57f7bb151bcda6b0f9bdbb7 | 12 | 23.168,00 | 25,3 |
| PE | 3 | 1d0997ff06b524ce9289ffd75114ecd3 | 3 | 3.747,00 | 4,1 |
| GO | 1 | 9d5a9018aee56acb367ba9c3f05d1d6a | 67 | 10.292,31 | 15,5 |
| GO | 2 | 750303a20e9c56b2a6bc45cdce0b897d | 54 | 8.085,00 | 12,2 |
| GO | 3 | b410bdd36d5db7a65dcd42b7ead933b8 | 44 | 7.726,90 | 11,7 |

Mostrando 30 de 57 linhas. Resultado completo em [`07_top_vendedores_por_uf.csv`](07_top_vendedores_por_uf.csv).

## Quantos vendedores respondem pela maior parte do faturamento?

Consulta: [`consultas/08_concentracao_de_vendedores.sql`](../consultas/08_concentracao_de_vendedores.sql)

| vendedores | vendedores_para_50pct | vendedores_para_80pct | vendedores_para_80pct_do_total |
| --- | --- | --- | --- |
| 3.053 | 129 | 540 | 17,7 |

## Como os clientes pagam?

Consulta: [`consultas/09_formas_de_pagamento.sql`](../consultas/09_formas_de_pagamento.sql)

| tipo | pedidos | pedidos_pct | valor_total | valor_medio | parcelas_media |
| --- | --- | --- | --- | --- | --- |
| credit_card | 76.505 | 76,9 | 12.542.084,19 | 163,32 | 3,5 |
| boleto | 19.784 | 19,9 | 2.869.361,27 | 145,03 | 1,0 |
| voucher | 3.866 | 3,9 | 379.436,87 | 65,70 | 1,0 |
| debit_card | 1.528 | 1,5 | 217.989,79 | 142,57 | 1,0 |

## Quanto o frete pesa no valor da compra em cada estado?

Consulta: [`consultas/10_peso_do_frete_por_uf.sql`](../consultas/10_peso_do_frete_por_uf.sql)

| uf | pedidos | ticket_medio | frete_medio | frete_sobre_produtos_pct |
| --- | --- | --- | --- | --- |
| RR | 45 | 171,99 | 49,10 | 28,5 |
| MA | 736 | 162,08 | 42,66 | 26,3 |
| RO | 246 | 187,12 | 46,31 | 24,7 |
| AM | 147 | 152,09 | 37,27 | 24,5 |
| PI | 490 | 176,86 | 43,07 | 24,4 |
| SE | 345 | 170,79 | 40,90 | 23,9 |
| TO | 278 | 177,73 | 42,07 | 23,7 |
| AC | 81 | 197,32 | 45,52 | 23,1 |
| RN | 482 | 172,27 | 39,13 | 22,7 |
| PE | 1.643 | 159,31 | 36,08 | 22,6 |
| PB | 531 | 216,34 | 48,30 | 22,3 |
| PA | 969 | 184,54 | 39,90 | 21,6 |
| CE | 1.323 | 171,02 | 36,48 | 21,3 |
| AP | 68 | 198,15 | 41,01 | 20,7 |
| AL | 411 | 195,41 | 38,72 | 19,8 |
| BA | 3.344 | 151,65 | 29,84 | 19,7 |
| MT | 902 | 173,30 | 32,92 | 19,0 |
| GO | 1.998 | 144,08 | 26,36 | 18,3 |
| RS | 5.415 | 137,13 | 24,88 | 18,1 |
| ES | 2.018 | 135,55 | 24,55 | 18,1 |
| PR | 4.982 | 135,87 | 23,55 | 17,3 |
| SC | 3.599 | 144,09 | 24,85 | 17,2 |
| MG | 11.496 | 136,87 | 23,45 | 17,1 |
| RJ | 12.697 | 142,68 | 23,95 | 16,8 |
| DF | 2.120 | 141,93 | 23,79 | 16,8 |
| MS | 708 | 164,91 | 27,01 | 16,4 |
| SP | 41.125 | 125,57 | 17,37 | 13,8 |
