# LucroAI — Guia de Migração Flutter para Microserviços

Este documento é o guia de referência para migrar o app Flutter do monólito (`:3000`) para a arquitetura de microserviços (`:3001`–`:3005`). A migração é feita módulo a módulo para que você possa testar e validar cada parte separadamente.

---

## 1. A Maior Mudança: URLs Base Fragmentadas

No monólito, **tudo saía de uma única base URL** (`:3000`). Nos microserviços, cada domínio tem seu próprio serviço.

| Domínio | Porta antiga | **Porta nova** | Rotas cobertas |
|---|---|---|---|
| Autenticação | :3000 | **:3001** | `/auth/*` |
| Ingredientes + Gastos | :3000 | **:3002** | `/insumos/*`, `/gastos-indiretos/*` |
| Receitas | :3000 | **:3003** | `/receitas/*` |
| Estoque + Produções | :3000 | **:3004** | `/estoque/*`, `/producoes/*` |
| Vendas | :3000 | **:3005** | `/vendas/*` |

**Recomendação:** criar uma classe `ApiConfig` no Flutter com uma constante por serviço:

```dart
class ApiConfig {
  static const String auth      = 'http://SEU_HOST:3001';
  static const String catalog   = 'http://SEU_HOST:3002';
  static const String recipe    = 'http://SEU_HOST:3003';
  static const String operations = 'http://SEU_HOST:3004';
  static const String sales     = 'http://SEU_HOST:3005';
}
```

---

## 2. Divergências de Comportamento (Quebras de Contrato)

Estas mudanças podem quebrar o app silenciosamente — sem stack trace óbvio. Leia antes de migrar qualquer tela.

| # | Comportamento antigo (monólito) | Comportamento novo (microserviços) | O que fazer no Flutter |
|---|---|---|---|
| **KD-1** | Campos extras no body → ignorados | Campos extras no body → **400 Bad Request** | Garantir que os modelos Dart serializam apenas os campos esperados |
| **KD-2** | Criar venda sem estoque → **400** | Criar venda sem estoque → **200** (aceita) | Se o app exibia "sem estoque", mover essa validação para o client |
| **KD-3** | `quantidadeDisponivel` atualiza síncronamente | Atualiza via RabbitMQ (eventual consistency, ~1–3s) | Não exibir o novo valor imediatamente após produção/venda; usar pull-to-refresh ou delay |
| **KD-4** | Lookup de insumo sem escopo de empresa | Lookup scoped pelo `empresa.id` no JWT | Garantir que o token usado tem o `empresa.id` correto |
| **KD-5** | Referências inválidas (FK) bloqueadas pelo banco | Sem FK entre serviços → IDs inválidos não são rejeitados | Validar IDs no Flutter antes de enviar |

---

## 3. Ambiente de Desenvolvimento

### Subir todos os serviços

```bash
cd lucroai-backend
docker compose up -d
docker compose ps   # confirmar que todos estão healthy
```

### Swagger de cada serviço (testar antes de migrar a tela)

| Serviço | URL |
|---|---|
| auth-service | http://localhost:3001/docs |
| catalog-service | http://localhost:3002/docs |
| recipe-service | http://localhost:3003/docs |
| operations-service | http://localhost:3004/docs |
| sales-service | http://localhost:3005/docs |
| RabbitMQ UI | http://localhost:15672 (admin / admin) |
| Adminer (banco) | http://localhost:8080 |

---

## 4. Migração por Módulo

> Para cada módulo: validar com curl/Postman → migrar a camada de API no Flutter → testar a tela.

---

### Módulo 1 — Autenticação (`auth-service :3001`)

**Impacto: mínimo.** Rotas e DTOs idênticos ao monólito. Só muda a porta.

#### Endpoints

| Método | Rota | Auth | Descrição |
|---|---|---|---|
| POST | `/auth/empresa` | Nenhum | Criar empresa + primeiro usuário |
| POST | `/auth/login` | Nenhum | Login e emissão de JWT |

#### Request — Cadastro de empresa
```json
{
  "nome_empresa": "Minha Empresa",
  "cnpj": "12.345.678/0001-90",
  "segmento": "Alimentício",
  "nome_usuario": "João Silva",
  "email": "joao@empresa.com",
  "senha": "minhasenha123"
}
```
> `cnpj` e `segmento` são opcionais.

#### Request — Login
```json
{
  "email": "joao@empresa.com",
  "senha": "minhasenha123"
}
```

#### Response (ambos os endpoints)
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIs...",
  "sub": 1,
  "email": "joao@empresa.com",
  "nome": "João Silva",
  "empresa": {
    "id": 1,
    "nome": "Minha Empresa",
    "cnpj": "12.345.678/0001-90",
    "segmento": "Alimentício"
  }
}
```

#### O que muda no Flutter
- Base URL: `ApiConfig.auth` (`:3001`)
- Token expira em **4 horas** — implementar interceptor de 401 para disparar re-login
- O mesmo token funciona em todos os 5 serviços (mesma `JWT_SECRET`)

#### Teste rápido
```bash
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"joao@empresa.com","senha":"minhasenha123"}'
```

---

### Módulo 2 — Ingredientes (`catalog-service :3002`)

**Auth: Bearer token obrigatório em todas as rotas.**

#### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| GET | `/insumos` | Listar ingredientes da empresa |
| GET | `/insumos/:id` | Buscar ingrediente por ID |
| POST | `/insumos` | Criar ingrediente |
| PATCH | `/insumos/:id` | Atualizar ingrediente (parcial) |
| DELETE | `/insumos/:id` | Excluir ingrediente (retorna 204) |

#### Request — Criar insumo
```json
{
  "empresaId": 1,
  "nome": "Farinha de Trigo",
  "quantidadeBaseCusto": 1.0,
  "quantidadeDisponivelInicial": 500.0,
  "unidade": "KG",
  "valorPago": 12.50
}
```
> `quantidadeDisponivelInicial` é opcional (padrão 0).

**Enum `unidade`:** `G` | `KG` | `ML` | `L` | `UN`

#### Request — Atualizar insumo (todos opcionais)
```json
{
  "nome": "Farinha Integral",
  "quantidadeBaseCusto": 1.0,
  "unidade": "KG",
  "valorPago": 15.00
}
```

#### Response — Insumo
```json
{
  "id": 1,
  "empresaId": 1,
  "nome": "Farinha de Trigo",
  "quantidadeBaseCusto": 1.0,
  "quantidadeDisponivel": 500.0,
  "unidade": "KG",
  "valorPago": 12.50,
  "custoUnitario": 12.50,
  "dataCriacao": "2024-06-18T10:00:00.000Z"
}
```

#### O que muda no Flutter
- Base URL: `ApiConfig.catalog` (`:3002`)
- **KD-1:** Modelo Dart deve serializar **somente** os campos acima — remover campos extras
- **KD-3:** `quantidadeDisponivel` pode estar desatualizado logo após operações de estoque

---

### Módulo 3 — Gastos Indiretos (`catalog-service :3002`)

**Auth: nenhum.**

#### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| POST | `/gastos-indiretos` | Criar gasto indireto |
| GET | `/gastos-indiretos?empresaId=1` | Listar por empresa |
| GET | `/gastos-indiretos/:id` | Buscar por ID |
| PUT | `/gastos-indiretos/:id` | Atualizar (substituição completa) |
| DELETE | `/gastos-indiretos/:id` | Excluir (retorna 204) |

#### Request — Criar/Atualizar
```json
{
  "empresa_id": 1,
  "descricao": "Aluguel da cozinha",
  "valor": 2000.00,
  "metodo_rateio": "PROPORCIONAL"
}
```

**Enum `metodo_rateio`:** `PROPORCIONAL` | `POR_UNIDADE` | `FIXO`

#### Response — Gasto Indireto
```json
{
  "id": 1,
  "empresaId": 1,
  "descricao": "Aluguel da cozinha",
  "valor": 2000.00,
  "metodo_rateio": "PROPORCIONAL",
  "dataCriacao": "2024-06-18T10:00:00.000Z"
}
```

#### O que muda no Flutter
- Base URL: `ApiConfig.catalog` (`:3002`) — mesmo serviço que insumos
- Este módulo **não exige Authorization header** — remover se estava sendo enviado
- O `PUT` é substituição completa (não PATCH) — enviar todos os campos

---

### Módulo 4 — Receitas (`recipe-service :3003`)

**Auth: nenhum.**

#### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| POST | `/receitas` | Criar receita |
| GET | `/receitas` | Listar receitas |
| GET | `/receitas/:id` | Buscar receita |
| PUT | `/receitas/:id` | Atualizar receita |
| DELETE | `/receitas/:id` | Excluir receita (retorna 204) |
| GET | `/receitas/:id/custo` | Calcular custo de produção |
| POST | `/receitas/:id/custo/simular` | Simular custo para N lotes |
| POST | `/receitas/:id/preco-venda` | Calcular preço de venda sugerido |

#### Request — Criar receita
```json
{
  "empresa_id": 1,
  "nome": "Bolo de Chocolate",
  "rendimento": 12,
  "unidadeRendimento": "UN",
  "margem_lucro": 0.40,
  "insumos": [
    { "insumo_id": 1, "quantidade": 0.5 },
    { "insumo_id": 2, "quantidade": 300.0 }
  ]
}
```
> `margem_lucro` é opcional (ex: `0.40` = 40% de margem).

#### Request — Simular custo
```json
{ "quantidadeLotes": 5 }
```

#### Request — Preço de venda
```json
{ "margemLucro": 0.40 }
```

#### Response — Custo da receita
```json
{
  "receitaId": 1,
  "nome": "Bolo de Chocolate",
  "custoProducao": 45.50,
  "custoUnitario": 3.79,
  "rendimento": 12,
  "margemLucro": 0.40,
  "precoSugerido": 5.31
}
```

#### O que muda no Flutter
- Base URL: `ApiConfig.recipe` (`:3003`)
- **KD-1:** O array `insumos` deve conter apenas `insumo_id` e `quantidade`

---

### Módulo 5 — Estoque (`operations-service :3004`)

**Auth: Bearer token obrigatório.**

#### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| GET | `/estoque/insumos/:id` | Ver nível de estoque atual |
| POST | `/estoque/insumos/:id/entrada` | Registrar entrada de compra |
| GET | `/estoque/insumos/:id/movimentacoes` | Histórico de movimentações |

#### Request — Registrar entrada
```json
{ "quantidade": 100.5 }
```

#### Response — Estoque
```json
{
  "id": 1,
  "insumoId": 1,
  "quantidadeDisponivel": 500.0,
  "quantidadeMinima": 100.0,
  "dataAlteracao": "2024-06-18T10:00:00.000Z"
}
```

#### Response — Movimentação
```json
{
  "id": 1,
  "insumoId": 1,
  "tipo": "ENTRADA",
  "origem": "COMPRA",
  "quantidade": 100.5,
  "referenciaId": null,
  "dataMovimentacao": "2024-06-18T10:00:00.000Z"
}
```

**Enum `tipo`:** `ENTRADA` | `SAIDA`  
**Enum `origem`:** `COMPRA` | `PRODUCAO`

#### O que muda no Flutter
- Base URL: `ApiConfig.operations` (`:3004`)
- **KD-3:** Após entrada, o `quantidadeDisponivel` em `/insumos` (catalog) leva ~1–3s para atualizar. Não fazer leitura imediata ou usar `Future.delayed` + pull-to-refresh

---

### Módulo 6 — Produções (`operations-service :3004`)

**Auth: nenhum.**

#### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| POST | `/producoes` | Registrar produção |
| GET | `/producoes?receitaId=1` | Listar por receita |
| GET | `/producoes/:id` | Buscar produção |

#### Request — Criar produção
```json
{
  "receita_id": 1,
  "quantidade": 5,
  "gasto_indireto_ids": [1, 2]
}
```
> `gasto_indireto_ids` é opcional.

#### Response — Produção
```json
{
  "id": 1,
  "receitaId": 1,
  "quantidade": 5,
  "custoTotal": 227.50,
  "custoUnitario": 3.79,
  "dataProducao": "2024-06-18T10:00:00.000Z",
  "rateiosProducao": [
    {
      "id": 1,
      "producaoId": 1,
      "gastoIndiretoId": 1,
      "valorRateado": 50.00
    }
  ]
}
```

#### O que muda no Flutter
- Base URL: `ApiConfig.operations` (`:3004`) — mesmo serviço que estoque
- **KD-3:** O estoque de insumos é debitado assincronamente — mesma observação do módulo de estoque

---

### Módulo 7 — Vendas (`sales-service :3005`)

**Auth: nenhum.**

#### Endpoints

| Método | Rota | Descrição |
|---|---|---|
| POST | `/vendas` | Criar venda |
| GET | `/vendas?empresaId=1&status=PENDENTE&dataInicio=&dataFim=` | Listar com filtros |
| GET | `/vendas/:id` | Buscar venda |
| PATCH | `/vendas/:id/status` | Atualizar status |

#### Request — Criar venda
```json
{
  "empresa_id": 1,
  "itens": [
    {
      "receita_id": 1,
      "quantidade": 12,
      "preco_unitario_real": 5.50
    }
  ]
}
```
> `preco_unitario_real` aceita no máximo **2 casas decimais**.

#### Request — Atualizar status
```json
{ "status": "CONCLUIDA" }
```

**Enum `status`:** `PENDENTE` | `CONCLUIDA` | `CANCELADA`

#### Response — Venda
```json
{
  "id": 1,
  "empresaId": 1,
  "total": 66.00,
  "status": "PENDENTE",
  "dataVenda": "2024-06-18T10:00:00.000Z",
  "itens": [
    {
      "id": 1,
      "vendaId": 1,
      "receitaId": 1,
      "quantidade": 12,
      "precoUnitarioReal": 5.50,
      "custoUnitario": 3.79,
      "margemRealizada": 0.31
    }
  ]
}
```

#### O que muda no Flutter
- Base URL: `ApiConfig.sales` (`:3005`)
- **KD-2:** Vender sem estoque agora retorna **200** (não 400) — se havia tratamento de erro para "sem estoque", mover validação para o client
- Aplicar `double.parse(value.toStringAsFixed(2))` em `preco_unitario_real` antes de enviar

---

## 5. Checklist de Migração

Use para rastrear o progresso tela a tela.

- [ ] **ApiConfig** — criar com 5 base URLs por serviço
- [ ] **Interceptor 401** — re-autenticar quando token expirar (4h)
- [ ] **Tela de Login / Cadastro** — base URL `:3001`
- [ ] **Tela de Insumos** — base URL `:3002`, limpar DTOs (KD-1)
- [ ] **Tela de Gastos Indiretos** — base URL `:3002`, remover auth header
- [ ] **Tela de Receitas** — base URL `:3003`
- [ ] **Tela de Custo de Receita** — base URL `:3003`
- [ ] **Tela de Estoque** — base URL `:3004`, UX para consistência eventual (KD-3)
- [ ] **Tela de Produções** — base URL `:3004`
- [ ] **Tela de Vendas** — base URL `:3005`, tratar KD-2, arredondar preço
- [ ] **Revisão geral** — verificar que nenhum modelo Dart envia campos extras (KD-1)

---

## 6. Verificação End-to-End

Execute este fluxo completo após migrar todas as telas para confirmar a integração:

```
1. POST :3001/auth/empresa        → Criar empresa e salvar token
2. POST :3002/insumos             → Criar 1 insumo, anotar ID
3. POST :3003/receitas            → Criar receita usando o insumo do passo 2
4. GET  :3003/receitas/:id/custo  → Verificar custo calculado
5. POST :3004/estoque/insumos/:id/entrada  → Registrar entrada de 500 unidades
6. GET  :3004/estoque/insumos/:id          → Aguardar ~2s, confirmar quantidadeDisponivel
7. POST :3004/producoes           → Criar produção de 5 lotes
8. POST :3005/vendas              → Criar venda de 3 unidades
9. PATCH :3005/vendas/:id/status  → { "status": "CONCLUIDA" }
10. GET :3004/estoque/insumos/:id/movimentacoes → Confirmar SAIDA registrada (aguardar ~2s)
```

> Os passos 6 e 10 exigem aguardar a consistência eventual do RabbitMQ (~1–3s).

---

## 7. Enums de Referência Rápida

| Enum | Valores |
|---|---|
| `unidade` | `G`, `KG`, `ML`, `L`, `UN` |
| `metodo_rateio` | `PROPORCIONAL`, `POR_UNIDADE`, `FIXO` |
| `status` (venda) | `PENDENTE`, `CONCLUIDA`, `CANCELADA` |
| `tipo` (movimentação) | `ENTRADA`, `SAIDA` |
| `origem` (movimentação) | `COMPRA`, `PRODUCAO` |
