# 📄 TESTING_STRATEGY.md

## 🎯 Princípio Base: TDD & BDD

Todo o desenvolvimento do **atos-logos-core** deve seguir estritamente o ciclo **Red-Green-Refactor**. Testes são escritos **antes** do código de produção para guiar o design e garantir **100% de cobertura**.

**Estilo:** "TDD com alma de BDD" — foco no comportamento do usuário.

**Padrão de Escrita:** Estrutura **Given-When-Then (DAMP)** dentro do código e nomenclatura `should [behavior] when [context]`.

---

## 🏛️ Organização dos Testes

### 1. Backend (NestJS)

- **Unitários (`*.spec.ts`)** — foco em Services e Controllers.
  - **Regra:** Mockar obrigatoriamente o Prisma Client e APIs externas.
  - **Local:** junto ao módulo em `src/modules/[module]/`.
- **E2E API (`*.e2e-spec.ts`)** — validação de rotas, Guards e persistência.
  - **Regra:** usar banco de dados real de testes (via Docker/Testcontainers).
  - **Local:** pasta `test/` na raiz do backend.

### 2. Frontend (Flutter)

- **Cubits (`bloc_test`)** — testar transições de estados (ex: `[Loading, Loaded]`).
  - **Local:** `test/features/[feature]/cubit/`.
- **Widgets (`flutter_test`)** — validar componentes e interações de UI.
  - **Local:** `test/features/[feature]/pages/` ou `test/shared/widgets/`.
- **Full-System (E2E)** — jornada real do usuário via **Patrol** ou **Maestro**.
  - **Local:** repositório/pasta de infraestrutura dedicada.

---

## 🛠️ Regras de Ouro (Checklist)

- **Sem testes vagos:** proibido `should work`. Use `should emit error state when credentials are invalid`.
- **F.I.R.S.T:** testes devem ser **F**ast, **I**ndependent, **R**epeatable, **S**elf-validating, **T**imely.
- **DAMP sobre DRY:** priorize a legibilidade do teste. Repetir o setup (Arrange) é melhor do que esconder a lógica em funções auxiliares complexas.
- **Edge Cases:** sempre testar falha de rede, e-mail duplicado, inputs vazios e timeouts.
- **Mocks de Fronteira:** moque apenas o que sai do seu domínio (APIs/Banco). Não moque objetos de valor ou entidades simples.

---

## 🔺 Pirâmide de Testes

Toda nova feature **deve** distribuir testes nas três camadas, na proporção clássica (base larga, topo estreito). Não basta empilhar e2e: a cobertura de bug regressiva vem dos unit; o e2e prova que tudo está conectado.

```
              /\
             /  \   E2E (poucos, caros, lentos)
            /----\  → smoke das jornadas críticas, banco/UI reais
           /      \
          /  INT   \  Integração / Widget (médios)
         /----------\  → DTOs, controllers HTTP, widgets, cubits
        /            \
       /     UNIT     \  Unitários (muitos, baratos, rápidos)
      /________________\ → services, helpers, models, enums
```

### Distribuição-alvo por feature

| Camada | Backend | Mobile | Proporção típica |
|---|---|---|---|
| **Unit** | services + helpers + DTO validation (mock Prisma) | enums + freezed models + cubits + repositories (mock Dio) | ~70% dos testes |
| **Integração** | controllers (mock service) | widget tests por página + grupos `Layout/Interactions/States/Navigation` | ~20% |
| **E2E** | `*.e2e-spec.ts` com Postgres real (testcontainers) | `integration_test/*.dart` em emulador via `flutter test integration_test/` ou `flutter drive` | ~10% |

### Regras práticas

- **Antes de escrever um e2e, pergunte:** "isso já está coberto por unit + integration?" Se sim, e2e só vale para a jornada (login → seleção igreja → home → ação).
- **Cada novo módulo backend ganha pelo menos 1 `*.e2e-spec.ts`** seguindo o padrão de `test/branches.e2e-spec.ts` (signup admin → bearer JWT → cenários positivos + 400/403/404/409 reais).
- **Cada novo flow mobile ganha pelo menos 1 arquivo em `integration_test/`** seguindo o padrão de `integration_test/auth_flow_test.dart`. Se não houver emulador, mantenha-o como widget-level "flow" test que exercita a navegação completa.
- **Não duplique cenários entre camadas.** O e2e verifica que o pipe está ligado; os unit tests cobrem permutações de input.

---

## 📊 Cobertura — Meta e Verificação

**Meta:** 100% de cobertura de linhas em todo arquivo tocado por uma feature, **ou** documentação explícita do teto real (com motivo).

### Comandos canônicos

**Backend:**
```bash
cd atos-logos-backend
npx jest --coverage          # gera coverage/, falha se thresholds em package.json não baterem
npx jest --config test/jest-e2e.json   # e2e separado
```

**Mobile:**
```bash
cd atos_logos_mobile
flutter test --coverage      # gera coverage/lcov.info
node tool/coverage_<flow>.js # report por flow (login, register, home, members, …)
```

### Workflow obrigatório ao fim de cada flow/módulo

1. Rodar coverage real (não confiar em "deve estar coberto").
2. Listar cada arquivo abaixo de 100% e cada linha não coberta.
3. Para cada gap, escolher uma das duas saídas:
   - **Fechar:** escrever o teste que cobre a linha (geralmente um caminho de erro, um branch nulo, um helper privado exercitado via boundary pública).
   - **Documentar:** adicionar exclusão **com motivo escrito** (ex: `// istanbul ignore next` no backend ou entrada no array `EXCLUSIONS` do `tool/coverage_<flow>.js` mobile). Motivos aceitáveis:
     - Decoradores `@IsEnum` / metadata gerada por TS para DI — branches internos ao class-validator
     - Closures debug-only (`LogInterceptor.logPrint`)
     - Caminhos UI inalcançáveis sem device real (`showDatePicker`, gesture recognizers)
4. Commitar a feature **somente** depois que o coverage report fechou (ou está documentado).

### Threshold no `package.json` (backend)

Cada arquivo crítico tem entrada própria em `coverageThreshold`. Ao adicionar campos novos a um DTO com `@IsEnum`, esperar que branches caia ~25% por enum — relaxar o threshold só desse arquivo, **nunca** do wildcard inteiro, e adicionar comentário no PR explicando.

### Reports por flow (mobile)

Existe um script por flow em `tool/coverage_<flow>.js` que filtra `lcov.info` para os arquivos daquele flow. **Toda feature nova ganha o seu** (copiar `tool/coverage_members.js` como template). Vantagem: report focado em vez de scroll por 200 arquivos.

### O que NÃO conta como cobertura

- Teste que só verifica `expect(widget, isNotNull)` — falsa segurança.
- Teste que mocka a função sob teste (mockar a si mesmo).
- Teste que nunca falha (sem assert ou com `expect(true, true)`).
- E2E que faz login e nada mais.

---

## 📝 Exemplos de Nomenclatura Padrão

### Backend — Service (unit)

```ts
describe('AuthService - login', () => {
  it('should return access_token and refresh_token when user has a single active membership');
  it('should return church selection payload when user has multiple active memberships');
  it('should throw Invalid credentials when password does not match');
  it('should throw Invalid credentials when user has no active memberships (prevents user enumeration)');
  it('should normalize email by trimming whitespace and lowercasing before lookup');
});

describe('AuthService - refresh', () => {
  it('should issue new token pair and revoke the old row on successful rotation');
  it('should detect reuse and revoke ALL user tokens when a revoked token is presented');
  it('should throw when refresh token is expired');
});
```

### Backend — Controller (unit)

```ts
describe('AuthController - login', () => {
  it('should forward email and password to AuthService.login');
  it('should return the service response unchanged');
});
```

### Backend — E2E (`*.e2e-spec.ts`)

```ts
describe('POST /auth/login (e2e)', () => {
  it('should return 200 with a token pair when credentials are valid');
  it('should return 401 when credentials are invalid');
  it('should return 400 when email is malformed');
  it('should return 429 after exceeding the rate limit');
});
```

### Frontend — Cubit (`bloc_test`)

```dart
group('AuthCubit - login', () {
  blocTest('should emit [loading, authenticated] when repository returns LoginSuccess');
  blocTest('should emit [loading, churchSelection] when repository returns LoginChurchSelection');
  blocTest('should emit [loading, error] with mapped PT-BR message on NetworkException');
  blocTest('should emit [loading, error] with "Erro inesperado" on generic exception');
});
```

### Frontend — Widget (`flutter_test`)

```dart
group('LoginPage - Layout', () {
  testWidgets('should display app logo and welcome headline');
  testWidgets('should not display "remember device" checkbox');
});

group('LoginPage - Interactions', () {
  testWidgets('should show validation error when email is empty');
  testWidgets('should reject malformed email');
  testWidgets('should trim whitespace from email before forwarding to login()');
  testWidgets('should submit login when keyboard "done" is pressed on password field');
});

group('LoginPage - States', () {
  testWidgets('should disable submit button while loading');
  testWidgets('should show error snackbar when state is error');
});

group('LoginPage - Navigation', () {
  testWidgets('should navigate to /home when state becomes authenticated');
  testWidgets('should navigate to /select-church when state becomes churchSelection');
});
```

### Padrão Given-When-Then dentro do teste (DAMP)

```ts
it('should return Invalid credentials when password does not match', async () => {
  // Given — an existing user with a known password hash
  const user = { id: 'u1', email: 'a@b.com', password: await bcrypt.hash('realpass', 1) };
  prisma.user.findUnique.mockResolvedValue(user);

  // When — login is attempted with the wrong password
  const attempt = service.login('a@b.com', 'wrongpass');

  // Then — an UnauthorizedException is thrown with the generic message
  await expect(attempt).rejects.toThrow('Invalid credentials');
});
```

---

## 🔄 Fluxo de Trabalho (Workflow)

1. **RED:** escreva um teste que descreve o comportamento esperado. Ele deve falhar.
2. **GREEN:** escreva o código mínimo necessário para o teste passar.
3. **REFACTOR:** limpe o código, remova duplicidades e melhore a arquitetura, garantindo que o teste continue passando.
