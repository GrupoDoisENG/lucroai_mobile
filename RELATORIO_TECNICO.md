# Relatório Técnico — LucroAI Mobile

**Disciplina:** Desenvolvimento de Aplicativos Mobile  
**Tecnologia:** Flutter / Dart  
**Repositório:** lucroai_mobile

---

## 1. Introdução do Aplicativo

### 1.1 Problema abordado

Pequenos e médios negócios do segmento alimentício — como confeitarias, restaurantes e lanchonetes — enfrentam dificuldade em controlar seus custos de produção de forma precisa. Sem uma ferramenta adequada, decisões como definir o preço de venda de um produto, saber se um item está sendo vendido com lucro real ou identificar quando o estoque de um insumo está acabando são feitas de forma intuitiva, o que frequentemente resulta em prejuízo.

### 1.2 Proposta da solução

O **LucroAI** é um aplicativo mobile desenvolvido em Flutter que centraliza a gestão financeira e operacional do negócio. Ele permite ao usuário:

- Cadastrar e gerenciar **insumos** (matérias-primas) com seus custos unitários calculados automaticamente;
- Criar **receitas** com os insumos cadastrados, obtendo custo de produção, custo unitário e preço sugerido de venda;
- **Simular cenários** de preço e volume para uma receita antes de tomar decisões;
- Registrar **vendas** e acompanhar o histórico com totais e ticket médio;
- Controlar o **estoque** de insumos e registrar entradas de material;
- Lançar **gastos indiretos** (aluguel, energia, etc.) que impactam o custo real do negócio;
- Visualizar um **dashboard** consolidado com os principais indicadores.

O aplicativo consome uma API REST composta por cinco microserviços e persiste a sessão do usuário localmente, garantindo que o login seja necessário apenas uma vez.

---

## 2. Arquitetura

### 2.1 Visão geral: Feature-First + Clean Architecture mapeada ao MVVM

O projeto adota a organização **Feature-First** (também chamada de *feature-driven* ou *modular*) como estratégia de organização de diretórios, aplicada sobre os princípios da **Clean Architecture**. Dentro de cada feature, as responsabilidades são divididas em três camadas que correspondem diretamente ao padrão **MVVM**:

```
lib/
├── core/                          # Infraestrutura compartilhada
│   ├── auth/                      # Sessão de autenticação
│   ├── di/                        # Injeção de dependências (GetIt)
│   ├── local/                     # Persistência local (Adapter)
│   ├── network/                   # Cliente HTTP e constantes
│   └── errors/                    # Exceções do domínio
│
└── features/
    ├── auth/
    ├── insumos/
    │   ├── data/                  # Camada de dados
    │   │   ├── datasources/       # Acesso à API (InsumoRemoteDatasource)
    │   │   ├── models/            # Serialização/deserialização JSON
    │   │   └── repositories/      # Implementação concreta do repositório
    │   ├── domain/                # Camada de domínio (regras de negócio)
    │   │   ├── entities/          # Entidades puras (Insumo, InsumoUnidadeMedida)
    │   │   ├── repositories/      # Interface abstrata do repositório
    │   │   └── usecases/          # Casos de uso (GetInsumosUsecase, etc.)
    │   └── presentation/          # Camada de apresentação
    │       ├── cubit/             # InsumosCubit + InsumosState (ViewModel)
    │       ├── pages/             # InsumosPage (View)
    │       └── widgets/           # Componentes visuais
    ├── receitas/
    ├── vendas/
    ├── estoques/
    ├── gastos_indiretos/
    ├── dashboard/
    └── simulacao/
```

### 2.2 Por que Feature-First?

A organização convencional de projetos Flutter agrupa arquivos por tipo — todas as pages em uma pasta, todos os cubits em outra, todos os models em outra. Isso funciona para projetos pequenos, mas à medida que o número de features cresce, encontrar e manter o código de uma funcionalidade específica exige navegar por múltiplos diretórios.

A abordagem **Feature-First** inverte essa lógica: os arquivos são agrupados pela funcionalidade a que pertencem, não pelo tipo técnico. Isso traz vantagens concretas:

| Critério | Layer-First (convencional) | Feature-First (adotado) |
|---|---|---|
| **Localização do código** | Espalhado em 3–4 pastas | Tudo de uma feature em um único lugar |
| **Impacto de mudanças** | Uma alteração em `Insumo` exige navegar por 4 diretórios | Mudanças ficam contidas em `features/insumos/` |
| **Escalabilidade** | Pastas crescem indefinidamente | Cada feature é um módulo coeso e isolado |
| **Onboarding** | Desenvolvedores precisam entender a estrutura global antes de tocar em qualquer coisa | Um desenvolvedor pode trabalhar em `features/vendas/` sem conhecer as demais |
| **Deleção de feature** | Requer varrer múltiplos diretórios e remover arquivos individuais | Basta deletar a pasta da feature |

No contexto deste projeto — com seis features independentes (insumos, receitas, vendas, estoques, gastos_indiretos, simulação) — a organização Feature-First permite que cada feature seja compreendida, modificada e testada de forma isolada.

### 2.3 Mapeamento para MVVM

O padrão **MVVM (Model–View–ViewModel)** é aplicado dentro de cada feature da seguinte forma:

#### Model

O **Model** é composto por três subcamadas que trabalham juntas para representar e acessar os dados:

- **Entity** (ex.: `Insumo`, `Receita`, `Venda`): classe Dart pura, imutável, sem dependência de framework. Representa o conceito de negócio.
- **Repository** (interface em `domain/repositories/` + implementação em `data/repositories/`): define o contrato de acesso a dados e isola a camada de apresentação de qualquer detalhe de infraestrutura.
- **UseCase** (ex.: `GetInsumosUsecase`, `CreateReceitaUsecase`): encapsula uma única operação de negócio e é o único ponto de entrada que o ViewModel acessa para obter ou modificar dados.

```dart
// Exemplo: entity pura — nenhuma dependência de framework
class Insumo {
  final int id;
  final String nome;
  final double custoUnitario;
  // ...
}

// Interface do repositório — o domain não sabe como os dados chegam
abstract class InsumoRepository {
  Future<List<Insumo>> getInsumos({String? search});
  Future<Insumo> createInsumo({...});
  // ...
}
```

#### ViewModel — Cubit

O **ViewModel** é implementado pelo `Cubit` de cada feature. Ele:

- Não contém nenhum código de UI (sem referência a `Widget`, `BuildContext` ou `Colors`);
- Expõe um estado imutável (`InsumosState`, `ReceitasState`, etc.) via stream reativo;
- Chama UseCases para executar operações de negócio;
- Emite novos estados que a View consome.

```dart
class InsumosCubit extends Cubit<InsumosState> {
  final GetInsumosUsecase getInsumosUsecase;
  final CreateInsumoUsecase createInsumoUsecase;

  Future<void> loadInsumos({String? search}) async {
    emit(state.copyWith(status: InsumosStatus.loading));
    try {
      final result = await getInsumosUsecase(search: search);
      emit(state.copyWith(status: InsumosStatus.success, insumos: result));
    } catch (e) {
      emit(state.copyWith(status: InsumosStatus.error, errorMessage: e.toString()));
    }
  }
}
```

#### View — Page / Widget

A **View** é a `Page` do Flutter. Ela:

- Não contém nenhuma regra de negócio;
- Observa o estado do Cubit via `BlocBuilder` e renderiza a UI de acordo;
- Delega todas as ações do usuário ao Cubit.

```dart
// InsumosPage apenas observa e delega — nenhuma lógica aqui
BlocBuilder<InsumosCubit, InsumosState>(
  builder: (context, state) {
    if (state.status == InsumosStatus.loading) return const CircularProgressIndicator();
    if (state.status == InsumosStatus.error)   return Text(state.errorMessage!);
    return ListView(children: state.insumos.map((i) => InsumoCard(insumo: i)).toList());
  },
)
```

#### Resumo do mapeamento

| MVVM | Implementação no projeto | Localização |
|---|---|---|
| **Model** | `Entity` + `UseCase` + `Repository` | `domain/` e `data/` de cada feature |
| **ViewModel** | `Cubit` + `State` | `presentation/cubit/` |
| **View** | `Page` + `Widget` | `presentation/pages/` e `presentation/widgets/` |

### 2.4 Injeção de dependências

O `GetIt` (pacote `get_it`) atua como o contêiner de injeção de dependências do projeto. Todas as instâncias são registradas em `lib/core/di/injection_container.dart` e resolvidas em tempo de execução sem acoplamento estático entre as camadas.

---

## 3. Padrões de Projeto

O projeto implementa múltiplos padrões de projeto. O padrão principal adicionalmente ao MVVM é o **Adapter**, aplicado na camada de persistência local.

### 3.1 Padrão Adapter (principal adicional)

#### O que é

O padrão **Adapter** (estrutural) converte a interface de uma classe existente em outra interface esperada pelo cliente. Ele permite que classes com interfaces incompatíveis trabalhem juntas sem modificar nenhuma das duas.

#### Por que foi escolhido

O `SharedPreferences` é uma biblioteca de terceiros com sua própria API (`getString`, `setString`, `remove`). Se o código de negócio dependesse diretamente dela, qualquer troca de biblioteca de armazenamento (por exemplo, migrar para `Hive` ou `SQLite` no futuro) exigiria alterar todos os pontos de uso espalhados pelo código.

O Adapter resolve isso definindo uma interface de domínio (`LocalDatasource`) com operações semânticas (`saveToken`, `loadToken`, `clearToken`) e fazendo com que a implementação concreta adapte o `SharedPreferences` a essa interface.

#### Onde foi aplicado

```
lib/core/local/
├── local_datasource.dart                      # Target (interface do domínio)
└── shared_preferences_local_datasource.dart   # Adapter (adapta SharedPreferences)
```

**Target — interface que o domínio conhece:**

```dart
// lib/core/local/local_datasource.dart
abstract class LocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> loadToken();
  Future<void> clearToken();
}
```

**Adapter — envolve o SharedPreferences (Adaptee):**

```dart
// lib/core/local/shared_preferences_local_datasource.dart
class SharedPreferencesLocalDatasource implements LocalDatasource {
  final SharedPreferences _prefs;            // Adaptee
  static const String _tokenKey = 'auth_token';

  SharedPreferencesLocalDatasource(this._prefs);

  @override
  Future<void> saveToken(String token) async => _prefs.setString(_tokenKey, token);

  @override
  Future<String?> loadToken() async => _prefs.getString(_tokenKey);

  @override
  Future<void> clearToken() async => _prefs.remove(_tokenKey);
}
```

O código de negócio em `main.dart` depende exclusivamente de `LocalDatasource`. Se a implementação for trocada, nenhuma linha fora de `injection_container.dart` precisa ser alterada.

### 3.2 Padrão Singleton

O `GetIt` mantém instâncias únicas de datasources, repositories e usecases via `registerLazySingleton` e `registerSingleton`. O `LocalDatasource` é registrado como singleton eager (`registerSingleton`) porque o `SharedPreferences` já está inicializado no momento do registro.

```dart
// injection_container.dart
sl.registerSingleton<LocalDatasource>(
  SharedPreferencesLocalDatasource(prefs),  // uma única instância em toda a app
);
```

O `AuthSession` também é um singleton implementado como classe estática com estado compartilhado globalmente — armazena o token JWT e dados do usuário em memória durante a sessão.

### 3.3 Padrão Factory Method

`ApiClient.create(baseUrl)` é um **Factory Method** que produz instâncias configuradas de `Dio`. O método centraliza a criação do cliente HTTP (timeout, headers, interceptors de autenticação e tratamento de 401) e é chamado cinco vezes no container de DI, uma para cada microserviço.

```dart
// lib/core/network/api_client.dart
class ApiClient {
  static Dio create(String baseUrl) {        // Factory Method
    final dio = Dio(BaseOptions(baseUrl: baseUrl, ...));
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['Authorization'] = 'Bearer ${AuthSession.token}';
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          AuthSession.clear();
          AuthSession.onUnauthorized?.call();
        }
        handler.next(error);
      },
    ));
    return dio;
  }
}
```

### 3.4 Padrão Observer

O `flutter_bloc` (Cubit) implementa o padrão **Observer** nativamente: o Cubit é o Sujeito (publica estados via stream) e os widgets que usam `BlocBuilder` são os Observadores (reagem automaticamente a mudanças de estado). Isso elimina callbacks manuais e garante que a UI sempre reflita o estado mais recente sem polling.

---

## 4. Integração com API

### 4.1 Arquitetura de microserviços

A API é composta por cinco microserviços independentes, cada um com sua própria URL base:

| Serviço | URL base | Responsabilidade |
|---|---|---|
| auth-service | `http://localhost:3001` | Login e autenticação |
| catalog-service | `http://localhost:3002` | Insumos e gastos indiretos |
| recipe-service | `http://localhost:3003` | Receitas, custo e simulação |
| operations-service | `http://localhost:3004` | Estoque e movimentações |
| sales-service | `http://localhost:3005` | Vendas e dashboard |

Cada serviço possui uma instância dedicada de `Dio`, configurada pelo `ApiClient.create()` e registrada no GetIt com um nome (`'auth'`, `'catalog'`, `'recipe'`, `'operations'`, `'sales'`).

### 4.2 Endpoints consumidos

| Método | Endpoint | Feature |
|---|---|---|
| POST | `/auth/login` | Autenticação |
| GET | `/insumos` | Listar insumos |
| POST | `/insumos` | Criar insumo |
| PUT | `/insumos/:id` | Editar insumo |
| DELETE | `/insumos/:id` | Remover insumo |
| GET | `/receitas` | Listar receitas |
| POST | `/receitas` | Criar receita |
| PUT | `/receitas/:id` | Editar receita |
| DELETE | `/receitas/:id` | Remover receita |
| POST | `/receitas/:id/simular` | Simulação de cenário |
| GET | `/vendas` | Listar vendas |
| POST | `/vendas` | Registrar venda |
| GET | `/vendas/dashboard` | Resumo do dashboard |
| GET | `/estoque/insumos/:id` | Consultar estoque |
| POST | `/estoque/insumos/:id/entrada` | Registrar entrada |
| GET | `/estoque/insumos/:id/movimentacoes` | Histórico de movimentações |
| GET | `/gastos-indiretos` | Listar gastos indiretos |
| POST | `/gastos-indiretos` | Criar gasto indireto |
| PUT | `/gastos-indiretos/:id` | Editar gasto indireto |
| DELETE | `/gastos-indiretos/:id` | Remover gasto indireto |

### 4.3 Fluxo de consumo

O fluxo segue a cadeia de responsabilidades da Clean Architecture:

```
View (Page)
  └─> Cubit.metodo()
        └─> UseCase.call()
              └─> Repository (interface)
                    └─> RepositoryImpl
                          └─> RemoteDatasource
                                └─> Dio.get/post/put/delete()
                                      └─> API REST
```

Exemplo concreto para carregamento de insumos:

1. `InsumosPage` chama `cubit.loadInsumos()`
2. `InsumosCubit` emite estado `loading` e chama `GetInsumosUsecase()`
3. `GetInsumosUsecase` chama `InsumoRepository.getInsumos()`
4. `InsumoRepositoryImpl` delega para `InsumoRemoteDatasource.getInsumos()`
5. O datasource executa `dio.get('/insumos')` e converte a resposta JSON em lista de `Insumo`
6. O cubit emite estado `success` com a lista; a View renderiza automaticamente

### 4.4 Tratamento de estados e erros

Todos os Cubits implementam os três estados exigidos para qualquer operação assíncrona:

```dart
// Exemplo em InsumosCubit
Future<void> loadInsumos() async {
  emit(state.copyWith(status: InsumosStatus.loading));   // carregamento
  try {
    final result = await getInsumosUsecase();
    emit(state.copyWith(                                   // sucesso
      status: InsumosStatus.success,
      insumos: result,
    ));
  } catch (e) {
    emit(state.copyWith(                                   // erro
      status: InsumosStatus.error,
      errorMessage: e.toString(),
    ));
  }
}
```

A View responde a cada estado de forma explícita via `BlocBuilder`, exibindo indicador de carregamento, os dados ou a mensagem de erro conforme o caso.

**Tratamento de autenticação expirada:** o interceptor de erro do `ApiClient` detecta respostas `HTTP 401`, limpa a sessão em memória e no disco, e aciona o callback `AuthSession.onUnauthorized`, que navega automaticamente para a tela de login.

---

## 5. Persistência Local

### 5.1 Tecnologia adotada

O aplicativo utiliza o pacote **`shared_preferences`** (versão `^2.3.3`) para persistência local. O `SharedPreferences` oferece armazenamento chave-valor em disco, adequado para dados leves como tokens de sessão e preferências do usuário.

A tecnologia é acessada exclusivamente através da interface `LocalDatasource`, seguindo o Padrão Adapter descrito na Seção 3.1. Isso garante que a camada de negócio permaneça desacoplada da implementação concreta.

### 5.2 O que é persistido e por quê

**Token JWT de autenticação** — chave `auth_token`

O token JWT é a única credencial necessária para autenticar todas as requisições à API. Persistindo-o no disco, o aplicativo consegue restaurar a sessão do usuário automaticamente ao ser reaberto, eliminando a necessidade de novo login.

**O que não é persistido intencionalmente:** dados das features (insumos, receitas, vendas, etc.) não são cacheados localmente. Como esses dados mudam com frequência e dependem do servidor para consistência, buscá-los sempre da API garante que o usuário veja informações atualizadas. O escopo da persistência é restrito à sessão.

### 5.3 Ciclo de vida da sessão persistida

```
App abre
  └─> main() inicializa SharedPreferences
        └─> initDependencies(prefs: prefs)
              └─> AuthGate._tryRestoreSession()
                    ├─ token encontrado → AuthSession.start(token) → MainScreen
                    └─ token ausente   → LoginPage

Login bem-sucedido
  └─> LocalDatasource.saveToken(token)
        └─> AuthSession.start(token) → MainScreen

Token expira (HTTP 401 em qualquer requisição)
  └─> ApiClient interceptor
        └─> AuthSession.clear()
              └─> LocalDatasource.clearToken()
                    └─> AuthGate reconstrói → LoginPage
```

### 5.4 Inicialização assíncrona

Como o `SharedPreferences.getInstance()` é assíncrono, o `main()` foi adaptado para aguardar a inicialização antes de registrar as dependências e iniciar o app:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();           // necessário para async no main
  final prefs = await SharedPreferences.getInstance(); // aguarda disco
  initDependencies(prefs: prefs);                      // injeta no GetIt
  runApp(const LucroAiApp());
}
```

Durante a verificação da sessão salva, o `AuthGate` exibe um indicador de carregamento para evitar flash de tela de login em usuários já autenticados.

---

## 6. Conclusão

### 6.1 Principais decisões técnicas

**Feature-First como estratégia de organização:** a escolha por organizar o código por feature em vez de por tipo técnico foi fundamental para manter o projeto navegável à medida que o número de funcionalidades cresceu. Com seis features independentes, o Feature-First garante que o impacto de qualquer mudança fique contido dentro dos limites da feature alterada.

**Clean Architecture dentro de cada feature:** a separação em camadas `data`, `domain` e `presentation` impõe regras de dependência claras (a camada de domínio não conhece a camada de dados) e permite substituir implementações sem afetar o restante do sistema. Por exemplo, trocar `SharedPreferences` por `Hive` exige apenas uma nova implementação de `LocalDatasource` e uma linha no `injection_container.dart`.

**BLoC/Cubit como ViewModel:** o Cubit foi escolhido sobre `ChangeNotifier` e `setState` por três razões: (1) separa completamente o estado da UI do código de apresentação, (2) implementa o padrão Observer nativamente via streams, e (3) torna o estado testável de forma isolada, sem instanciar widgets.

**Adapter para persistência:** o padrão Adapter foi aplicado propositalmente na camada de persistência para demonstrar como isolar a dependência de uma biblioteca de terceiros. A interface `LocalDatasource` é um contrato estável; a implementação com `SharedPreferences` é um detalhe que pode ser trocado sem impacto no restante da aplicação.

**GetIt como container de DI:** a injeção de dependências via `GetIt` elimina o acoplamento estático entre camadas e centraliza a composição do sistema em um único arquivo (`injection_container.dart`), facilitando a compreensão e a manutenção da aplicação.

### 6.2 Limitações e melhorias futuras

| Limitação atual | Melhoria sugerida |
|---|---|
| Ausência de testes automatizados | Implementar testes unitários nos UseCases e Cubits, e testes de widget nas Pages |
| Token JWT não é validado localmente antes do restore | Verificar a expiração do token (`exp` no payload JWT) em `_tryRestoreSession` e limpar se expirado |
| Dados não são cacheados offline | Adicionar um datasource local (ex.: `Hive` ou `sqflite`) para cachear insumos e receitas e permitir leitura sem conexão |
| URLs dos microserviços fixas no código | Mover para variáveis de ambiente com `--dart-define` para facilitar a troca entre ambientes (desenvolvimento, homologação, produção) |
| Sem tratamento de refresh token | Implementar fluxo de refresh token automático antes do 401, evitando logout forçado em sessões longas |
| Ausência de feedback de progresso em operações de escrita | Adicionar indicadores de carregamento localizados (em botões) em vez de bloquear a tela inteira |
