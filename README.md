# LucroAI Mobile

Aplicativo mobile desenvolvido em Flutter para gestão financeira e operacional de pequenos negócios do segmento alimentício.

---

## Descrição do app

O LucroAI resolve um problema comum em confeitarias, restaurantes e lanchonetes: a dificuldade de saber, com precisão, quanto custa produzir cada item e se ele está sendo vendido com lucro real.

O aplicativo permite:

- **Insumos** — cadastrar matérias-primas com quantidade e valor pago; o custo unitário é calculado automaticamente
- **Receitas** — criar receitas com os insumos cadastrados e obter custo de produção, custo unitário e preço sugerido de venda com base em margem de lucro definida pelo usuário
- **Simulação de cenários** — simular diferentes preços e volumes de venda para uma receita antes de tomar decisões
- **Vendas** — registrar vendas e acompanhar o histórico com total vendido e ticket médio por período
- **Estoque** — controlar o saldo de cada insumo e registrar entradas de material
- **Gastos indiretos** — lançar custos fixos (aluguel, energia, etc.) que impactam o custo real do negócio
- **Dashboard** — visualizar os principais indicadores do negócio em uma tela consolidada

---

## Como executar

### Pré-requisitos

- Flutter SDK `^3.9.2`
- Dart SDK `^3.9.2`
- Android Studio ou Xcode (para emulador/dispositivo)
- Backend rodando localmente (cinco microserviços nas portas 3001–3005)

### Instalação

```bash
# Clone o repositório
git clone <url-do-repositorio>
cd lucroai_mobile

# Instale as dependências
flutter pub get
```

### Execução

```bash
# Android (emulador ou dispositivo físico)
flutter run

# iOS
flutter run --device-id <id-do-simulador>

# Verificar dispositivos disponíveis
flutter devices
```

### Build de produção

```bash
# Android
flutter build apk --release

# iOS
flutter build ipa --release
```

---

## Padrão de projeto escolhido

### Adapter

O padrão **Adapter** foi aplicado na camada de persistência local. O problema: o código de negócio não pode depender diretamente da biblioteca `SharedPreferences`, pois isso criaria acoplamento com uma implementação de terceiro e dificultaria futuras trocas de tecnologia.

A solução define uma interface de domínio (`LocalDatasource`) com operações semânticas e uma classe adaptadora (`SharedPreferencesLocalDatasource`) que traduz essas operações para a API do `SharedPreferences`:

```
LocalDatasource (interface)          ← o domínio conhece apenas isso
    └── SharedPreferencesLocalDatasource (Adapter)
            └── SharedPreferences (biblioteca de terceiro)
```

```dart
// Target — interface que o restante da aplicação usa
abstract class LocalDatasource {
  Future<void> saveToken(String token);
  Future<String?> loadToken();
  Future<void> clearToken();
}

// Adapter — envolve o SharedPreferences e adapta sua API
class SharedPreferencesLocalDatasource implements LocalDatasource {
  final SharedPreferences _prefs;
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

Além do Adapter, o projeto também utiliza:

- **Singleton** — `GetIt` mantém instâncias únicas de datasources, repositories e usecases via `registerLazySingleton`
- **Factory Method** — `ApiClient.create(baseUrl)` produz instâncias configuradas de `Dio` com autenticação e tratamento de erros
- **Observer** — o `flutter_bloc` (Cubit) implementa o padrão Observer: a View observa o estado do Cubit e é reconstruída automaticamente a cada mudança

---

## API utilizada

A aplicação consome uma API REST composta por cinco microserviços:

| Serviço | Porta | Responsabilidade |
|---|---|---|
| auth-service | `3001` | Login e autenticação JWT |
| catalog-service | `3002` | Insumos e gastos indiretos |
| recipe-service | `3003` | Receitas, custos e simulação |
| operations-service | `3004` | Estoque e movimentações |
| sales-service | `3005` | Vendas e dashboard |

As URLs base são definidas em `lib/core/network/api_constants.dart`. Cada serviço possui uma instância dedicada de `Dio`, configurada com:

- Header `Authorization: Bearer <token>` injetado automaticamente em todas as requisições
- Timeout de 10 segundos para conexão e recebimento
- Interceptor de erro que detecta respostas `401` e encerra a sessão automaticamente

---

## Solução de armazenamento local

**Pacote:** `shared_preferences ^2.3.3`

**O que é persistido:** o token JWT de autenticação, sob a chave `auth_token`.

**Por quê apenas o token:** os dados das features (insumos, receitas, vendas, etc.) são sempre buscados da API para garantir consistência. O token é o único dado que precisa sobreviver ao fechamento do app — ele permite restaurar a sessão sem exigir um novo login.

**Ciclo de vida:**

| Evento | Ação |
|---|---|
| App abre | Lê o token do disco; se existir, restaura a sessão e vai para a tela principal |
| Login bem-sucedido | Salva o token no disco |
| Token expira (HTTP 401) | Apaga o token do disco e redireciona para o login |

A persistência é acessada exclusivamente pela interface `LocalDatasource`, registrada como Singleton no `GetIt`. Isso desacopla o restante da aplicação da implementação concreta — trocar `SharedPreferences` por outro mecanismo exige apenas uma nova implementação da interface e uma linha no container de DI.
