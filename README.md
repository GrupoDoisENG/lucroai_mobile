# LucroAI Mobile

Aplicativo desenvolvido em Flutter para gestão financeira e operacional de pequenos negócios do segmento alimentício.

---

## Descrição do app

O LucroAI resolve um problema comum em confeitarias, restaurantes e lanchonetes: a dificuldade de saber, com precisão, quanto custa produzir cada item e se ele está sendo vendido com lucro real.

O aplicativo oferece as seguintes funcionalidades:

| Tela | Descrição |
|---|---|
| **Dashboard** | Indicadores consolidados do negócio; acesso rápido à simulação de cenários |
| **Insumos** | Cadastro de matérias-primas com quantidade e valor pago; custo unitário calculado automaticamente |
| **Receitas** | Criação de receitas com insumos cadastrados; exibe custo de produção, custo unitário e preço sugerido com base em margem definida pelo usuário |
| **Custos** | Lançamento de gastos indiretos fixos (aluguel, energia, etc.) que impactam o custo real do negócio |
| **Vendas** | Registro e acompanhamento de vendas com validação de estoque antes de concluir |
| **Estoque** | Saldo de cada insumo; registro de entradas de material e histórico de movimentações |
| **Produções** | Registro de lotes produzidos por receita; alimenta o cálculo de estoque disponível para vendas |
| **Simulação** | Simula diferentes preços e volumes de venda para uma receita (acessível pelo botão na Home) |

---

## Como executar

### Pré-requisitos

- Flutter SDK `^3.9.2`
- Dart SDK `^3.9.2`
- Backend rodando localmente (cinco microserviços nas portas 3001–3005)

### Instalação

```bash
git clone <url-do-repositorio>
cd lucroai_mobile
flutter pub get
```

### Execução

```bash
# Chrome (alvo recomendado para desenvolvimento)
flutter run -d chrome

# Android (emulador ou dispositivo físico)
flutter run -d android

# Verificar dispositivos disponíveis
flutter devices
```

> **Nota Android:** se o build travar com erro de JVM, adicione a linha abaixo em `android/gradle.properties`:
> ```
> org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=2g
> ```

### Build de produção

```bash
flutter build apk --release   # Android
flutter build ipa --release   # iOS
```

---

## Arquitetura

O projeto segue **Feature-First Clean Architecture**, onde cada funcionalidade é um módulo independente com três camadas:

```
lib/
├── core/
│   ├── auth/           # Sessão JWT (AuthSession singleton)
│   ├── di/             # Injeção de dependências (GetIt)
│   ├── network/        # ApiClient, ApiConstants
│   └── widgets/        # Widgets compartilhados
└── features/
    ├── auth/
    ├── dashboard/
    ├── insumos/
    ├── receitas/
    ├── simulacao/
    ├── custos/
    ├── gastos_indiretos/
    ├── vendas/
    ├── estoques/
    └── producoes/
```

Cada feature segue a estrutura:

```
<feature>/
├── data/
│   ├── datasources/    # Chamadas HTTP (Dio)
│   ├── models/         # JSON → entidade (fromJson)
│   └── repositories/   # Implementação do repositório
├── domain/
│   ├── entities/       # Objetos de domínio puros
│   ├── repositories/   # Contrato (abstract class)
│   └── usecases/       # Um caso de uso por arquivo
└── presentation/
    ├── cubit/          # Estado e lógica (flutter_bloc)
    └── pages/          # Widgets e telas
```

### Navegação

A shell principal (`AppShellPage`) usa `IndexedStack` + `AppBottomNav` com sete abas:

| Índice | Aba | Cubit(s) fornecido(s) |
|---|---|---|
| 0 | Home | `ReceitasCubit`, `VendasCubit`, `EstoquesCubit` |
| 1 | Insumos | — (gerenciado internamente) |
| 2 | Receitas | `ReceitasCubit` |
| 3 | Custos | — (gerenciado internamente) |
| 4 | Vendas | `VendasCubit` |
| 5 | Estoque | `EstoquesCubit` |
| 6 | Produções | `ProducoesCubit` |

A tela de **Simulação** não é uma aba — é acessada via `Navigator.push` a partir do botão na Home, recebendo `ReceitasCubit` e `VendasCubit` via `BlocProvider.value`.

---

## Padrões de projeto

### Adapter

Aplicado na camada de persistência local. `SharedPreferencesLocalDatasource` adapta a API do `SharedPreferences` para a interface `LocalDatasource`, desacoplando o domínio da biblioteca concreta:

```
LocalDatasource (interface)
    └── SharedPreferencesLocalDatasource (Adapter)
            └── SharedPreferences (biblioteca de terceiro)
```

```dart
abstract class LocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> loadToken();
  Future<void> clearToken();
}
```

### Singleton

`GetIt` mantém instâncias únicas de datasources, repositórios e casos de uso via `registerLazySingleton`. Cubits são registrados como `registerFactory` para garantir uma instância fresca por tela.

### Factory Method

`ApiClient.create(baseUrl)` produz instâncias configuradas de `Dio` com bearer token e interceptor de 401:

```dart
class ApiClient {
  static Dio create(String baseUrl) { ... }
}
```

Cada microserviço tem sua própria instância nomeada no container de DI (`authDio`, `catalogDio`, `recipeDio`, `operationsDio`, `salesDio`).

### Observer

O `flutter_bloc` (Cubit) implementa o padrão Observer: as Views observam o estado do Cubit via `BlocBuilder`/`BlocConsumer` e são reconstruídas automaticamente a cada emissão.

---

## API

A aplicação consome uma API REST composta por cinco microserviços:

| Serviço | Porta | Responsabilidade |
|---|---|---|
| auth-service | `3001` | Login e autenticação JWT |
| catalog-service | `3002` | Insumos e gastos indiretos |
| recipe-service | `3003` | Receitas, custos e simulação |
| operations-service | `3004` | Estoque, movimentações e produções |
| sales-service | `3005` | Vendas e dashboard |

Todas as instâncias de `Dio` são configuradas com:

- Header `Authorization: Bearer <token>` injetado automaticamente
- Timeout de 10 segundos para conexão e recebimento
- Interceptor que detecta `401` e encerra a sessão via `AuthSession.clear()`

---

## Armazenamento local

**Pacote:** `shared_preferences ^2.3.3`

Apenas o token JWT é persistido (chave `auth_token`). Todos os dados de negócio são sempre buscados da API para garantir consistência.

| Evento | Ação |
|---|---|
| App abre | Lê o token; se existir, restaura a sessão |
| Login bem-sucedido | Salva o token |
| HTTP 401 | Apaga o token e redireciona para o login |
