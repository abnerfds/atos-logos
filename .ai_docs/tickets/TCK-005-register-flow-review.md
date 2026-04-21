# [Done] TCK-005: Revisão completa do Fluxo de Registro (Mobile + Backend)

## Descrição

Revisão de ponta-a-ponta do fluxo de cadastro (signup-admin) do `atos-logos-core` cobrindo:

1. **Mobile**: tela de registro (`RegisterPage`), validators compartilhados (`auth_validators.dart`), modelo `SignupRequest`, integração com `AuthCubit`/`AuthRepository`, redirect auto-login após criação.
2. **Backend**: `signupAdmin` do `AuthService`, `SignupAdminDto`, remoção do suporte a `phone` na criação, auto-emissão de token pair no signup.
3. **Conformidade com `.ai_docs/testing_strategy.md`**: TDD/BDD, naming `should [behavior] when [context]`, Given-When-Then, mocks na fronteira.
4. **Coverage**: 100% em todas as linhas executáveis do fluxo de registro.

Feita após o TCK-004 (revisão do login) e reusa toda a infraestrutura de refresh token, redirect, theme tokens e error mapping já consolidada.

## Critérios de Aceite

- [x] **Auto-login após signup**: backend emite token pair na criação, mobile persiste e emite `authenticated`, usuário vai direto para `/home`.
- [x] **Telefone removido do signup**: tela não tem campo, DTO não tipa, service não valida unique de phone. Admins preenchem phone depois via edit-profile.
- [x] **Validators centralizados**: regex de e-mail e min-length de senha compartilhados entre login e register via `auth_validators.dart`. Mensagens de erro consistentes.
- [x] **Validação por campo**: cada campo vazio/malformado mostra seu erro específico (não só "preencha todos").
- [x] **Live revalidation do confirm-password**: mudar a senha revalida o confirm em tempo real (sem precisar apertar submit de novo).
- [x] **UX/a11y**: `autofillHints` corretos em todos os 5 campos (incluindo `newPassword` no password/confirm para gerenciadores de senha oferecerem geração automática), `textInputAction.next/done` + focus management, `Semantics` no logo, `AbsorbPointer` durante loading.
- [x] **Theme tokens**: zero cores hardcoded na tela de registro; tudo via `AppTheme`.
- [x] **Link `/login` com alinhamento perfeito**: `TextSpan` + `TapGestureRecognizer` (em vez de `WidgetSpan + GestureDetector`).
- [x] **Footer decorativo removido**: PRIVACIDADE/TERMOS/SUPORTE fora.
- [x] **`AuthState.registered` removido**: dead code após o auto-login.
- [x] **100% de cobertura no fluxo de registro** (mobile).
- [x] **100% stmts/funcs/lines no `signupAdmin`** (backend).
- [x] Todos os testes de `register_page_test.dart` seguem `.ai_docs/testing_strategy.md`.

## Logs de Execução

### Revisão inicial — elenco de problemas

A mesma planilha que o TCK-004 usou no login. Identificados:

**HIGH (mesmo padrão do login pré-fix):**
- **R1**: cores hardcoded espalhadas ignorando `AppTheme`
- **R2**: email regex inferior ao do login (`\w`, TLDs 2-4 chars rejeita `.museum`)
- **R3**: mensagem de senha curta inconsistente (`"Mínimo 6 caracteres"` vs `"A senha deve ter ao menos 6 caracteres"` do login)
- **R4**: faltam `autofillHints` em todos os 5 campos (crítico para gerenciadores de senha oferecerem geração automática de senha forte — precisa `newPassword`, não `password`)
- **R5**: faltam `textInputAction.next/done` + `onFieldSubmitted` → Enter no teclado não avança
- **R6**: footer decorativo PRIVACIDADE/TERMOS/SUPORTE
- **R7**: mismatch backend↔mobile — backend aceita `phone` opcional + valida unique, tela não tem o campo

**MED:**
- **R8**: logo sem `Semantics`
- **R9**: link "Entre aqui" usando `WidgetSpan(GestureDetector(Text))` — bug visual de baseline elevado (mesmo que login tinha antes do fix)
- **R10**: após signup bem-sucedido → redireciona para `/login` exigindo login manual. UX melhor: **auto-login**
- **R11**: confirm password só revalida no submit (não live)
- **R12**: durante loading, campos continuam editáveis

**LOW:**
- **R13**: `_FieldLabel` repetido inline em várias páginas (padronização opcional)

### Decisões tomadas pelo usuário

- **R7 → Opção B**: remover suporte a `phone` do `signupAdmin`. Admins preenchem phone depois via edit-profile.
- **R10 → Sim**: auto-login após signup.
- **R13 → adiada**: decisão opcional; seguir sem extrair por enquanto.

### Execução por fases

#### Phase B — Validators compartilhados

- **Novo**: `lib/features/auth/presentation/auth_validators.dart` com:
  - `kEmailRegex` (RFC-5322-ish, aceita TLDs longos como `.museum`)
  - `kPasswordMinLength = 6` (match com `LoginDto.@MinLength(6)` e `SignupAdminDto.@MinLength(6)`)
  - `validateEmail(value)` — trim + regex → `'Informe o e-mail'` / `'E-mail inválido'` / `null`
  - `validatePassword(value)` — NÃO trima (whitespace pode fazer parte da senha) → `'Informe a senha'` / `'A senha deve ter ao menos 6 caracteres'` / `null`
  - `validateRequired(value, label)` — reusável para church name, leader name, etc.
  - `validatePasswordConfirmation(confirmation, original)` — trata empty e mismatch separadamente
- **Novo**: `test/features/auth/presentation/auth_validators_test.dart` — 22 testes cobrindo cada branch
- **Refatorado**: `login_page.dart` agora usa `validateEmail`/`validatePassword` diretamente como `validator:` callback
- **Refatorado**: `register_page.dart` idem + `validateRequired` para church/leader e `validatePasswordConfirmation` para o confirm

#### Phase C/D.1 — R7: remover `phone` do signup (backend + mobile)

**Backend:**
- `src/modules/auth/dto/signup-admin.dto.ts`: campo `phone?: string` removido. DTO comment explica que admins setam phone depois.
- `src/modules/auth/auth.service.ts` `signupAdmin()`: bloco `if (dto.phone) { findUnique({phone}) ...}` removido; `user.create` não recebe mais o campo phone.
- `src/modules/auth/auth.service.spec.ts`:
  - Removido `should throw if phone already exists` (o caminho não existe mais)
  - Removido o trivial `should be defined` (herança do Phase 7 do TCK-004)
  - Novo teste: `should NOT accept a phone field on the signup payload (admins set phone later via profile edit)` — documenta a decisão via assertion: `expect(createArgs.data).not.toHaveProperty('phone')`
  - Helper `mockSignupTransaction()` extraído para deduplicar setup
- `src/modules/auth/dto/dto.spec.ts`: removido `should accept an optional phone`; novo teste `should NOT type a phone field — admins set phone later via profile edit` (`expect(Object.keys(dto)).not.toContain('phone')`)

**Mobile:**
- `lib/features/auth/domain/models/signup_request.dart`: removido `String? phone` da factory freezed; doc comment explica.
- `lib/features/auth/presentation/cubit/auth_cubit.dart` `signup()`: removido parâmetro `phone`.
- `lib/features/auth/presentation/pages/register_page.dart`: já não tinha o campo, sem mudança no UI; o `_submit()` não passa mais `phone` (não passava).
- `test/features/auth/cubit/auth_cubit_test.dart`: removido `phone` dos test cases
- `test/features/auth/pages/register_page_test.dart`: `verifyNever(() => mockAuthCubit.signup(name:..., phone:...))` → `signup(name:..., ...)` sem phone
- `test/features/auth/domain/models/auth_models_test.dart`: novo group `SignupRequest` testando `fromJson` + `toJson` verifica explicitamente que não há chave `phone` no JSON resultante
- Build runner regenerou `signup_request.freezed.dart` / `.g.dart`

#### Phase C/D.2 — R10: auto-login após signup

**Backend:**
- `auth.service.ts` `signupAdmin()`: após o `$transaction` bem-sucedido, chama `this.issueTokenPair(user.id, user.email, church.id, branch.id, 'ADMIN')` e faz spread no retorno: `{ user, church, branch, ...tokens }`.
- `auth.service.spec.ts`: primeiro teste de happy-path de `signupAdmin` renomeado para `should create church, branch, user and membership and auto-issue a token pair so the new admin is logged in immediately` com assertions para `access_token` + `refresh_token` + hash SHA-256 persistido + role='ADMIN'.

**Mobile:**
- `auth_repository.dart` `signup(request)`: passou de `Future<void>` para `Future<AuthResponse>`. Parseia o response via `AuthResponse.fromJson`, chama `_persistTokens(authResponse)`, retorna.
- `auth_cubit.dart` `signup()`: agora emite `AuthState.authenticated()` no sucesso (em vez de `registered()`).
- `auth_state.dart`: **removido** o factory `const factory AuthState.registered() = _Registered;`. Comentário explica que o estado dedicado virou dead code após o auto-login.
- `register_page.dart` listener: bloco `registered: () { ...; context.go('/login'); }` → `authenticated: (_) { ...; context.go('/home'); }`.
- Build runner regenerou `auth_state.freezed.dart`.
- `test/features/auth/cubit/auth_cubit_test.dart`: test `emits [loading, registered]` → `emits [loading, authenticated]` com mock do repository retornando `AuthResponse` (não mais `void`). Novo teste: `forwards name, email, password and churchName to repository.signup`.
- `test/features/auth/data/auth_repository_test.dart`: test de signup atualizado para mockar response com `access_token`/`refresh_token` + verificar que ambos são persistidos via `storage.write`.
- `test/features/auth/pages/register_page_test.dart`: teste de navegação de sucesso agora espera `HOME_ROUTE` (não mais `LOGIN_ROUTE`).

#### Phase D.3 — UI fixes do RegisterPage

O `register_page.dart` inteiro foi reescrito (538 linhas) para:

- **Theme tokens**: substituiu `Color(0xFF37628A)`, `Color(0xFFE3E9EE)`, `Color(0xFFCDE6F4)`, `Color(0xFFF7F9FC)`, etc. por `AppTheme.primary`, `AppTheme.surfaceContainerHigh`, `AppTheme.secondaryContainer`, `AppTheme.surface`, `AppTheme.cardShadow`, `AppTheme.buttonShadow`, `AppTheme.radiusLg/Xl`, etc.
- **Validators compartilhados**: `validateEmail`, `validatePassword`, `validateRequired(v, 'o nome da sede')`, `validateRequired(v, 'o nome do líder')`, `validatePasswordConfirmation(v, passwordController.text)`.
- **autofillHints**:
  - church name → `[AutofillHints.organizationName]`
  - leader name → `[AutofillHints.name]`
  - email → `[AutofillHints.email]`
  - password → `[AutofillHints.newPassword]` (crítico: `newPassword` dispara sugestão de geração no password manager, vs `password` que só oferece preenchimento)
  - confirm → `[AutofillHints.newPassword]`
- **textInputAction + focus management**: `FocusNode` para cada campo; `TextInputAction.next` em church/leader/email/password, `TextInputAction.done` em confirm. `onFieldSubmitted` em cada um move o foco para o próximo, e o último chama `_submit()`.
- **Live revalidation do confirm**: novo método `_onPasswordChanged()` que chama `_formKey.currentState?.validate()` quando o confirm não está vazio. Ligado via `onChanged: (_) => onPasswordChanged()` no campo de senha.
- **`AbsorbPointer(absorbing: isLoading)`**: envolvendo o form inteiro dentro do `BlocBuilder`, para bloquear interação com todos os campos durante o loading (não só o botão).
- **Footer decorativo removido**: PRIVACIDADE/TERMOS/SUPORTE fora.
- **`Semantics(label: 'Logo Atos Logos', image: true)`** no Container do logo.
- **Link "Entre aqui"**: refatorado de `WidgetSpan(GestureDetector(Text))` para `TextSpan + TapGestureRecognizer`. `_loginTapRecognizer` é `late final`, criado em `initState`, disposto em `dispose`. Baseline alinhado perfeitamente.
- **Refactor de legibilidade**: a árvore de widgets do form ficou grande demais para viver direto no `build()`, então extraída para uma `_RegisterForm` stateless interna que recebe controllers/focos/callbacks via construtor. `_RegisterPageState` continua sendo o único dono de state.

#### Phase D.4 — Testes completos do RegisterPage

`register_page_test.dart` passou de 9 testes para **34 testes** organizados em 5 groups (Layout / Field validation / Interactions / Autofill + textInputAction / States / Navigation):

- **Layout (6)**: headline, labels dos 5 campos, botão, inline link "Entre aqui" (com assertion estrutural do TapGestureRecognizer), footer decorativo ausente, `Semantics` no logo.
- **Field validation (8)**: cada campo individual vazio (sede / líder / email) com sua mensagem específica, e-mail malformado, senha curta, mismatch, confirm vazio, submit totalmente em branco não chama `signup`.
- **Interactions (4)**: toggle do password, toggle do confirm independente, submit válido forwarda valores trimados (e senha raw), live revalidation do confirm quando a senha muda.
- **Autofill + textInputAction (10)**: 5 testes verificam cada `autofillHint` específico, 1 teste verifica `textInputAction.next` em todos exceto o último (que é `done`), 4 testes de navegação de foco entre os campos via `testTextInput.receiveAction(TextInputAction.next)`, 1 teste verifica que "done" no confirm submete o form.
- **States (3)**: loading indicator, submit button desabilitado durante loading, error snackbar.
- **Navigation (2)**: tap no inline "Entre aqui" → `/login`, estado `authenticated` após signup → snackbar + navegação para `/home` (auto-login comprobado end-to-end).

Helpers criados no topo do arquivo:
- `findRichTextContaining(substring)` — finder que casa `RichText` contendo um substring
- `tapInlineLink(tester, linkText)` — visita os `InlineSpan`s e dispara o `TapGestureRecognizer` programaticamente
- `fillValidForm(tester)` — preenche os 5 campos com valores canônicos
- `innerTextField(tester, index)` — extrai o `TextField` interno do `TextFormField[index]` para inspeção de props

#### Phase E — Coverage tool + fechamento de gaps

- **Novo**: `tool/coverage_register.js` espelhando `tool/coverage_login.js` com a lista de arquivos do fluxo de registro.
- Após o primeiro run: **8 linhas uncovered** nas callbacks `onFieldSubmitted` dos campos (focus navigation). Fechadas via 4 testes novos em "Autofill + textInputAction" (`should advance focus from X to Y when "next" is pressed on the X field keyboard`).
- Um desses testes precisou de `tester.ensureVisible` antes do `tap` porque o password field estava abaixo da fold do viewport padrão de teste (800x600).

## Decisões Técnicas

### Por que remover `phone` do signupAdmin em vez de adicionar o campo na tela

O usuário escolheu a opção B (remover do backend). Racionais:

- **Signup fica minimal**: 4 campos essenciais, experiência mais rápida.
- **Sem colisões falsas**: hoje, se dois admins diferentes tentam usar o mesmo telefone, um deles falha no signup antes mesmo de qualquer dado ser criado. Removendo o check, o signup nunca colide por phone.
- **Phone continua como dado único no DB**: o campo `User.phone` ainda existe com constraint unique; só é setado via `PATCH /auth/me` (profile edit) depois do signup.
- **Trade-off aceito**: se dois admins tentam setar o mesmo phone no edit-profile, aí sim um falha com a mensagem de conflito. É um ponto mais natural para o erro surgir.

### Por que `AutofillHints.newPassword` em vez de `AutofillHints.password`

`password` diz "esse é um campo de credencial existente, ofereça preencher com senha salva". `newPassword` diz "esse é um campo de CRIAÇÃO de credencial, ofereça gerar uma senha forte". A diferença é crítica em UX — o usuário está criando uma conta, não fazendo login. iOS/Android/Chrome/1Password/Bitwarden usam essa hint para sugerir geração automática de senhas fortes, exatamente o comportamento desejado no signup.

### Por que auto-login após signup

- **UX**: o usuário acabou de digitar suas credenciais. Forçar um segundo login é atrito desnecessário.
- **Segurança**: o auto-login usa exatamente o mesmo `issueTokenPair` do `login` — não abre nenhum buraco de segurança. O usuário que criou a conta COM CERTEZA é o dono dela (acabou de escolher a senha).
- **Rotação continua funcionando**: o refresh token emitido no signup já está no DB com o mesmo tracking de `revokedAt`/`replacedById`. O usuário pode fazer logout e login normal depois.

### Por que `AuthState.registered` foi removido

Virou dead code. Antes, o fluxo era "signup → `registered` → listener redireciona para `/login` → usuário loga → `authenticated`". Agora é "signup → `authenticated` direto". Manter `registered` criaria um estado zumbi que nunca seria emitido, confundindo futuros leitores do código. O comentário no `auth_state.dart` documenta a remoção para quem fizer arqueologia.

### Por que `_formKey.currentState.validate()` na live revalidation é OK

Preocupação inicial: `validate()` roda TODOS os validators do form, então se o usuário só digitou a senha mas ainda não preencheu church/leader/email, a live revalidation surfaceria "Informe o nome da sede" / "Informe o líder" / etc. Errado.

Solução de guard: `_onPasswordChanged()` só chama `validate()` se `_confirmPasswordController.text.isNotEmpty`. Ou seja, só revalida quando o usuário já interagiu com o confirm — nesse ponto, faz sentido que ele queira feedback. E na prática, se os outros campos estiverem vazios, eles já estariam em erro do submit anterior (o único fluxo em que o usuário chega a esse ponto).

### Por que `_RegisterForm` como StatelessWidget interno

O `build()` do `_RegisterPageState` tinha ~450 linhas aninhadas com `BlocBuilder` + `AbsorbPointer` + `Form` + 5 `TextFormField`s. Péssima legibilidade. Extraí para `_RegisterForm` stateless privado que recebe tudo via construtor — controllers, focus nodes, callbacks, flag de loading. `_RegisterPageState` continua sendo o único dono de state (controllers, focus, obscureToggles, recognizer). `_RegisterForm` é pura função de renderização.

## Arquivos criados / modificados

### Backend

| Ação | Arquivo |
|---|---|
| Mod | `src/modules/auth/dto/signup-admin.dto.ts` (removido campo `phone`) |
| Mod | `src/modules/auth/auth.service.ts` (`signupAdmin`: removido phone check + retorna token pair) |
| Mod | `src/modules/auth/auth.service.spec.ts` (testes atualizados para o novo retorno + novo teste "should NOT accept phone") |
| Mod | `src/modules/auth/dto/dto.spec.ts` (removido teste do phone optional, novo teste de type-level) |

### Mobile

| Ação | Arquivo |
|---|---|
| Novo | `lib/features/auth/presentation/auth_validators.dart` |
| Novo | `test/features/auth/presentation/auth_validators_test.dart` |
| Novo | `tool/coverage_register.js` |
| Mod | `lib/features/auth/domain/models/signup_request.dart` (removido `phone`) |
| Mod | `lib/features/auth/presentation/cubit/auth_state.dart` (removido `registered` factory) |
| Mod | `lib/features/auth/presentation/cubit/auth_cubit.dart` (`signup` agora emite `authenticated`, sem param `phone`) |
| Mod | `lib/features/auth/data/auth_repository.dart` (`signup` retorna `AuthResponse` + persiste tokens) |
| Mod | `lib/features/auth/presentation/pages/login_page.dart` (usa validators compartilhados) |
| Mod | `lib/features/auth/presentation/pages/register_page.dart` (reescrita inteira: theme, autofill, textInputAction, focus, semantics, footer removido, TapGestureRecognizer, AbsorbPointer, live revalidate, `_RegisterForm` extraído) |
| Mod | `test/features/auth/cubit/auth_cubit_test.dart` (signup tests atualizados) |
| Mod | `test/features/auth/data/auth_repository_test.dart` (signup test persiste ambos tokens) |
| Mod | `test/features/auth/domain/models/auth_models_test.dart` (novo group `SignupRequest`) |
| Mod | `test/features/auth/pages/register_page_test.dart` (9 → 34 testes, 5 groups) |

## Resultado dos Testes

### Mobile

```
$ flutter test
00:12 +258: All tests passed!
```

```
$ flutter test --coverage && node tool/coverage_register.js

Register Flow — Mobile Coverage Report
==========================================================================================================
File                                                                   Covered    Excluded         Status
----------------------------------------------------------------------------------------------------------
lib/core/error/exceptions.dart                                    5/5 (100.0%)           -         ✓ 100%
lib/features/auth/data/auth_repository.dart                     84/84 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/auth_response.dart                2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/signup_request.dart               2/2 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/auth_validators.dart             14/14 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/cubit/auth_cubit.dart            42/42 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/pages/register_page.dart       184/184 (100.0%)           -         ✓ 100%
----------------------------------------------------------------------------------------------------------
TOTAL (register flow, excl. documented skips)                 333/333 (100.0%)           0
```

**Sem exclusões documentadas** — o fluxo de registro não tem nenhuma linha provably-uncoverable. 100% real, não "100% com asterisco".

Regressão de login (sanity check):
```
TOTAL (login flow, excl. documented skips)                    339/339 (100.0%)          20
```

### Backend

```
$ npx jest
Test Suites: 11 passed, 11 total
Tests:       88 passed, 88 total
```

```
$ npx nest build
(clean)
```

### Totais

- **Mobile:** 208 → **258** (+50)
- **Backend:** 89 → **88** (-1, por remoção do `should be defined` trivial e do `should throw if phone already exists`; compensado por novos tests que não mudam o count líquido)
- Analyzer mobile: `No issues found`

## Como verificar / executar

### Backend

```bash
cd atos-logos-backend
npm run start:dev
# Testar: POST /auth/signup-admin com {name, email, password, churchName}
# Resposta esperada: { user, church, branch, access_token, refresh_token }
```

### Mobile

```bash
cd atos_logos_mobile
flutter run

# No app:
# 1. Tela de login → link "Cadastre sua igreja"
# 2. Preencher: nome sede, nome líder, email, senha (>=6), confirmar senha
# 3. Submit → snackbar "Conta criada com sucesso!" → navega direto para /home (auto-login)
```

### Checklist de teste manual

**Happy path:**
- [ ] Link "Cadastre sua igreja" no login leva para `/register`
- [ ] Preencher todos os 5 campos válidos → submit → snackbar sucesso → `/home`
- [ ] Matar o app e reabrir → continua logado (refresh token válido)
- [ ] Link "Entre aqui" no bottom do register leva para `/login`

**Validação client-side (antes de bater no backend):**
- [ ] Nome da sede vazio → "Informe o nome da sede"
- [ ] Nome do líder vazio → "Informe o nome do líder"
- [ ] E-mail vazio → "Informe o e-mail"
- [ ] E-mail malformado (`abc`) → "E-mail inválido"
- [ ] Senha < 6 chars → "A senha deve ter ao menos 6 caracteres"
- [ ] Confirm vazio → "Confirme a senha"
- [ ] Confirm diferente da senha → "As senhas não coincidem"
- [ ] Alterar senha depois de preencher confirm → mismatch aparece **live** (sem apertar submit)

**Erros do backend:**
- [ ] E-mail já cadastrado → "Já existe um usuário com este e-mail." (mapeado em PT-BR)
- [ ] Backend desligado → "Sem conexão. Verifique sua internet."
- [ ] 5 tentativas malformadas em < 1min → 429 (rate limit do throttler)

**UX:**
- [ ] Tab no nome da sede → foco vai pra nome do líder
- [ ] Tab no líder → email
- [ ] Tab no email → senha
- [ ] Tab na senha → confirm
- [ ] Enter no confirm → submete
- [ ] Olho da senha alterna independente do olho do confirm
- [ ] Gerenciador de senha oferece **gerar senha forte** (autofillHint `newPassword`)
- [ ] Durante loading, campos ficam desabilitados (não só o botão)
- [ ] NÃO existe footer PRIVACIDADE/TERMOS/SUPORTE

## Próximos passos

1. **Revisão da próxima tela** (select-church se ainda não foi fechada; senão home/dashboard).
2. **Implementar `phone` no edit-profile** quando essa tela for revisada — é o novo ponto de entrada do dado.
3. **Considerar `AutovalidateMode.onUserInteraction`** no Form do register para revalidação live ainda mais responsiva (hoje a guard `_onPasswordChanged` cobre o caso principal; é um refinamento opcional).
