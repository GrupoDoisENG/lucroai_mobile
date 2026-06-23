# RF-04 — Gastos Indiretos (Custos Invisíveis)

**Status:** Totalmente implementado no backend.

Os gastos indiretos são persistidos no banco, consultáveis via CRUD e automaticamente incluídos no custo
de cada receita. Quando uma produção é registrada, o rateio é calculado e armazenado junto à produção.

---

## Portas de serviço

| Ambiente | URL base |
|---|---|
| Monolith (dev) | `http://localhost:3000` |
| catalog-service | `http://localhost:3002` |

Em produção use a variável de ambiente `CATALOG_SERVICE_URL` / `MONOLITH_URL`.

---

## Autenticação

Todas as rotas exigem JWT no header:

```
Authorization: Bearer <token>
```

O token é obtido via `POST /auth/login`. O `empresaId` é extraído automaticamente do JWT — o Flutter
não precisa enviar nenhum campo `empresa_id` em rotas autenticadas.

---

## Enum `metodoRateio`

| Valor | Comportamento |
|---|---|
| `FIXO` | O valor total do gasto é somado ao custo da produção, independente da quantidade de lotes ou unidades |
| `POR_UNIDADE` | `valor × totalUnidades` (lotes × rendimento da receita) |
| `PROPORCIONAL` | `valor × quantidadeLotes` |

---

## Endpoints CRUD

### Criar gasto indireto

```
POST /gastos-indiretos
Content-Type: application/json
Authorization: Bearer <token>
```

**Body:**
```json
{
  "descricao": "Aluguel da cozinha",
  "valor": 1500.00,
  "metodo_rateio": "FIXO"
}
```

| Campo | Tipo | Obrigatório | Descrição |
|---|---|---|---|
| `descricao` | string (max 100) | sim | Nome do gasto |
| `valor` | number (≥ 0) | sim | Valor em R$ |
| `metodo_rateio` | enum | sim | `FIXO`, `POR_UNIDADE` ou `PROPORCIONAL` |

**Resposta 201:**
```json
{
  "id": 3,
  "empresaId": 1,
  "descricao": "Aluguel da cozinha",
  "valor": 1500.0,
  "metodoRateio": "FIXO"
}
```

---

### Listar gastos da empresa

```
GET /gastos-indiretos
Authorization: Bearer <token>
```

**Resposta 200:**
```json
[
  {
    "id": 1,
    "empresaId": 1,
    "descricao": "Aluguel da cozinha",
    "valor": 1500.0,
    "metodoRateio": "FIXO"
  },
  {
    "id": 2,
    "empresaId": 1,
    "descricao": "Energia elétrica",
    "valor": 300.0,
    "metodoRateio": "PROPORCIONAL"
  }
]
```

Retorna apenas os gastos da empresa do usuário autenticado.

---

### Buscar por ID

```
GET /gastos-indiretos/:id
Authorization: Bearer <token>
```

**Resposta 200:** mesmo objeto acima.  
**Resposta 404:**
```json
{ "message": "Gasto indireto não encontrado", "statusCode": 404 }
```

---

### Atualizar gasto

```
PUT /gastos-indiretos/:id
Content-Type: application/json
Authorization: Bearer <token>
```

**Body (todos opcionais):**
```json
{
  "descricao": "Aluguel atualizado",
  "valor": 1800.00,
  "metodo_rateio": "POR_UNIDADE"
}
```

**Resposta 200:** objeto atualizado.

---

### Deletar gasto

```
DELETE /gastos-indiretos/:id
Authorization: Bearer <token>
```

**Resposta 204:** sem body.

---

## Como os gastos aparecem no custo das receitas

Ao consultar o custo de uma receita, o campo `custoInvisivel` já reflete a soma dos gastos indiretos
calculados para 1 lote:

```
GET /receitas/:id/custo
Authorization: Bearer <token>
```

**Resposta 200:**
```json
{
  "custoIngredientes": 12.50,
  "custoInvisivel": 18.75,
  "custoProducao": 31.25,
  "custoUnitario": 3.125,
  "rendimento": 10,
  "precoSugerido": 5.50,
  "margemLucro": 0.4318
}
```

| Campo | Descrição |
|---|---|
| `custoIngredientes` | Soma do custo de todos os insumos da receita para 1 lote |
| `custoInvisivel` | Soma do rateio de todos os gastos indiretos para 1 lote |
| `custoProducao` | `custoIngredientes + custoInvisivel` (custo total de 1 lote) |
| `custoUnitario` | `custoProducao / rendimento` (custo por unidade produzida) |
| `rendimento` | Quantidade de unidades que 1 lote produz |
| `precoSugerido` | Preço de venda sugerido (cadastrado na receita) |
| `margemLucro` | `(precoSugerido - custoUnitario) / precoSugerido` |

---

## Erros possíveis

| Código | Mensagem | Causa |
|---|---|---|
| 400 | Validation failed | Body inválido (campo obrigatório ausente ou tipo errado) |
| 401 | Unauthorized | Token ausente ou expirado |
| 404 | Gasto indireto não encontrado | ID não existe ou pertence a outra empresa |

---

## Sugestões de UX para o Flutter

### Tela de Gerenciamento de Gastos Indiretos

1. **Lista de gastos** — `GET /gastos-indiretos` ao entrar na tela
2. **Criação** — formulário com campos `descricao`, `valor` (teclado numérico) e seletor de `metodo_rateio`
3. **Seletor de método de rateio** — mostrar com rótulo amigável:
   - `FIXO` → "Valor fixo por produção"
   - `POR_UNIDADE` → "Proporcional ao total de unidades"
   - `PROPORCIONAL` → "Proporcional à quantidade de lotes"
4. **Edição inline** — swipe para editar; `PUT /gastos-indiretos/:id`
5. **Exclusão** — swipe para deletar com confirmação; `DELETE /gastos-indiretos/:id`

### Tela de Custo da Receita

Ao exibir o custo (`GET /receitas/:id/custo`), mostre um breakdown visual:

```
Custo da receita
├── Ingredientes          R$ 12,50
└── Gastos indiretos      R$ 18,75
    ────────────────────────────────
    Custo total (1 lote)  R$ 31,25
    Custo por unidade     R$  3,13
    Margem (preço R$ 5,50)   43,2%
```

Botão "Gerenciar gastos indiretos" que navega para a tela acima.

### Indicação de impacto

Antes de criar ou editar um gasto, pode mostrar: "Este gasto afetará o custo de todas as suas receitas
automaticamente na próxima consulta."
