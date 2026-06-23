# RF-06 — Registrar Produção e Controle de Estoque

**Status:** Totalmente implementado no backend.

Ao registrar uma produção, o backend executa automaticamente:
1. Calcula o rateio dos gastos indiretos sobre os lotes produzidos
2. Persiste o registro da produção com custo total e custo unitário
3. **Baixa automática de estoque** de cada ingrediente (insumo) da receita
4. **Entrada automática no estoque de produto acabado** (unidades produzidas)

Nenhuma chamada adicional do Flutter é necessária — um único `POST /producoes` dispara tudo.

---

## Portas de serviço

| Ambiente | URL base |
|---|---|
| Monolith (dev) | `http://localhost:3000` |
| operations-service | `http://localhost:3004` |

---

## Autenticação

```
Authorization: Bearer <token>
```

---

## Fluxo completo

```
Flutter
  │
  └─ POST /producoes ──────────────────────────────────────────────► Backend
                                                                         │
                                                        Busca receita e itens
                                                                         │
                                                        Calcula rateio de gastos indiretos
                                                                         │
                                                        Cria Producao (custoTotal, custoUnitario)
                                                                         │
                                                        Para cada ingrediente da receita:
                                                          Estoque[insumo] -= quantidade × lotes
                                                                         │
                                                        EstoqueProdutoAcabado[receita] += totalUnidades
                                                                         │
  ◄──────────────────────────────────────── retorna Producao criada ────┘
```

---

## Registrar uma produção

```
POST /producoes
Content-Type: application/json
Authorization: Bearer <token>
```

**Body:**
```json
{
  "receita_id": 5,
  "quantidade": 3,
  "gasto_indireto_ids": [1, 2]
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `receita_id` | integer | sim | ID da receita a produzir |
| `quantidade` | integer (> 0) | sim | Número de lotes a produzir |
| `gasto_indireto_ids` | integer[] | não | IDs dos gastos a ratear. **Se omitido, usa todos os gastos indiretos da empresa automaticamente** |

**Resposta 201:**
```json
{
  "id": 12,
  "receitaId": 5,
  "quantidade": 3,
  "custoTotal": 56.25,
  "custoUnitario": 1.875,
  "dataProducao": "2026-06-22T14:35:00.000Z",
  "rateios": [
    { "gastoIndiretoId": 1, "valorRateado": 1500.00 },
    { "gastoIndiretoId": 2, "valorRateado": 900.00 }
  ]
}
```

| Campo resposta | Descrição |
|---|---|
| `id` | ID da produção criada |
| `receitaId` | Receita produzida |
| `quantidade` | Lotes produzidos |
| `custoTotal` | `(custoIngredientes × lotes) + totalRateioGastos` |
| `custoUnitario` | `custoTotal / (quantidade × rendimentoReceita)` |
| `dataProducao` | Timestamp ISO 8601 |
| `rateios` | Array com o valor rateado de cada gasto indireto |

### Cálculo de `custoTotal`

```
totalUnidades    = quantidade × receita.rendimento
custoIngredientes = receita.custoProducao × quantidade

Para cada gasto:
  FIXO        → valorRateado = gasto.valor
  PROPORCIONAL → valorRateado = gasto.valor × quantidade
  POR_UNIDADE  → valorRateado = gasto.valor × totalUnidades

custoTotal   = custoIngredientes + Σ(valorRateado)
custoUnitario = custoTotal / totalUnidades
```

---

## Listar produções

```
GET /producoes
Authorization: Bearer <token>
```

**Query params opcionais:**

| Param | Tipo | Descrição |
|---|---|---|
| `receitaId` | integer | Filtra produções de uma receita específica |

**Resposta 200:**
```json
[
  {
    "id": 12,
    "receitaId": 5,
    "quantidade": 3,
    "custoTotal": 56.25,
    "custoUnitario": 1.875,
    "dataProducao": "2026-06-22T14:35:00.000Z",
    "rateios": [...]
  }
]
```

---

## Buscar produção por ID

```
GET /producoes/:id
Authorization: Bearer <token>
```

**Resposta 200:** mesmo objeto acima.  
**Resposta 404:** `{ "message": "Produção não encontrada", "statusCode": 404 }`

---

## Consultar estoque de insumos

### Estoque atual de um insumo

```
GET /estoque/insumos/:insumoId
Authorization: Bearer <token>
```

**Resposta 200:**
```json
{
  "insumoId": 7,
  "quantidadeDisponivel": 4.5,
  "quantidadeMinima": 0,
  "dataAlteracao": "2026-06-22T14:35:00.000Z"
}
```

Se o insumo nunca teve movimentação, `quantidadeDisponivel` retorna `0`.

---

### Histórico de movimentações de um insumo

```
GET /estoque/insumos/:insumoId/movimentacoes
Authorization: Bearer <token>
```

**Resposta 200:**
```json
[
  {
    "id": 31,
    "insumoId": 7,
    "tipo": "SAIDA",
    "origem": "PRODUCAO",
    "quantidade": 1.5,
    "referenciaId": 12,
    "dataMovimentacao": "2026-06-22T14:35:00.000Z"
  },
  {
    "id": 20,
    "insumoId": 7,
    "tipo": "ENTRADA",
    "origem": "COMPRA",
    "quantidade": 6.0,
    "referenciaId": null,
    "dataMovimentacao": "2026-06-20T10:00:00.000Z"
  }
]
```

| Campo | Descrição |
|---|---|
| `tipo` | `ENTRADA` (compra) ou `SAIDA` (produção) |
| `origem` | `COMPRA` ou `PRODUCAO` |
| `referenciaId` | ID da produção que gerou a saída (null para entradas de compra) |

Ordenado do mais recente ao mais antigo.

---

### Registrar entrada de estoque (compra de insumo)

```
POST /estoque/insumos/:insumoId/entrada
Content-Type: application/json
Authorization: Bearer <token>
```

**Body:**
```json
{
  "quantidade": 10.0
}
```

**Resposta 200:** objeto de estoque atualizado com novo `quantidadeDisponivel`.

---

## Erros possíveis

| Código | Mensagem | Causa |
|---|---|---|
| 400 | Validation failed | Body inválido ou `quantidade` ≤ 0 |
| 401 | Unauthorized | Token ausente ou expirado |
| 404 | Receita não encontrada | `receita_id` inválido |
| 404 | Gasto indireto não encontrado | ID em `gasto_indireto_ids` inválido |
| 503 | catalog-service indisponível | Serviço de catálogo fora do ar (microservices) |

---

## Sugestões de UX para o Flutter

### Tela de Registrar Produção

**Campos do formulário:**
1. **Receita** — dropdown ou busca (`GET /receitas`) — exibir nome + rendimento
2. **Quantidade de lotes** — campo numérico inteiro (mínimo 1)
3. **Gastos indiretos** *(opcional, colapsável)* — multi-select de gastos (`GET /gastos-indiretos`).
   Texto sugestivo: "Se nenhum for selecionado, todos os gastos da empresa serão aplicados"

**Após submissão bem-sucedida (`POST /producoes`):**

Exibir card de resumo com:
```
✅ Produção registrada!

Receita: Bolo de Chocolate
Lotes:   3 × 10 unid = 30 unidades

Custo total:     R$ 56,25
Custo unitário:  R$  1,88

Estoque de ingredientes baixado automaticamente.
Produto acabado adicionado ao estoque.
```

**Botão "Ver estoque"** que navega para a tela de estoque.

---

### Tela de Estoque de Insumos

1. **Listar insumos** — `GET /insumos` com quantidade disponível via `GET /estoque/insumos/:id`
2. **Indicador visual** de nível:
   - Verde: quantidade > 0
   - Amarelo: quantidade baixa (< quantidade mínima, se configurada)
   - Vermelho: quantidade = 0
3. **Detalhes** ao tocar no insumo → `GET /estoque/insumos/:id/movimentacoes`
4. **Registrar compra** → formulário simples com `quantidade` → `POST /estoque/insumos/:id/entrada`

---

### Tela de Histórico de Produções

```
GET /producoes               → todas as produções da empresa
GET /producoes?receitaId=5   → produções de uma receita específica
```

Mostrar lista ordenada por data, com:
- Nome da receita (buscar via `GET /receitas/:id`)
- Data de produção
- Quantidade de lotes
- Custo total

Ao tocar: `GET /producoes/:id` → detalhe com rateios.
