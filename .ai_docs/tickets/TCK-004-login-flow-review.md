# [Done] TCK-004: Revisão completa do Fluxo de Login (Mobile + Backend)

## Descrição

Revisão de ponta-a-ponta do fluxo de login do `atos-logos-core` cobrindo:

1. **Mobile**: tela de login (`LoginPage`), `AuthCubit`, `AuthRepository`, modelos freezed do auth, `AuthInterceptor` (Dio), redirect do `GoRouter`, refresh token client.
2. **Backend**: `AuthController`, `AuthService`, DTOs (`LoginDto`, `SignupAdminDto`, `SelectChurchDto`, `RefreshDto`), `JwtStrategy`, `JwtAuthGuard`, `AuthModule`, fail-fast de configuração, rate-limiting, refresh-token rotation com reuse detection.
3. **Conformidade com `.ai_docs/testing_strategy.md`**: TDD/BDD, naming `should [behavior] when [context]`, organização por feature, F.I.R.S.T, mocks só na fronteira.
4. **Coverage**: 100% no fluxo de login (com exclusões intencionais documentadas).

A revisão foi feita após a implementação inicial das telas, com o objetivo de garantir que o login estivesse pronto para produção antes de avançar para os outros fluxos do app.

## Critérios de Aceite

- [x] Sessão persistente: usuário fica logado entre reinícios do app via `flutter_secure_storage` + boot-time refresh.
- [x] Login multi-igreja: backend retorna `selectionToken` + lista de igrejas; mobile redireciona para `/select-church`.
- [x] Mensagens de erro do backend traduzidas para PT-BR no client (não vazam strings em inglês).
- [x] Nenhum vazamento de existência de usuário (`No active membership found` → `Invalid credentials`).
- [x] Validação client-side alinhada com o backend: e-mail (regex) + senha ≥ 6 chars.
- [x] UX/a11y: `autofillHints`, `textInputAction`, focus management, `Semantics` no logo.
- [x] Tema centralizado: zero cores hardcoded em `login_page.dart`; tudo via `AppTheme`.
- [x] Refresh token com rotação e detecção de reuso (revoga todas as sessões em caso de detecção).
- [x] Rate-limit estrito em `/auth/login` (5 req/min/IP), `/auth/signup-admin` (5/min) e `/auth/select-church` (10/min).
- [x] `JWT_SECRET` validado no boot do servidor (falha fast se vazio, default fraco ou < 32 chars em produção).
- [x] CTA de cadastro acessível na tela de login (link inline para `/register`).
- [x] 100% de cobertura nas linhas executáveis do fluxo de login (mobile), com exclusões documentadas.
- [x] 100% stmts/funcs/lines no módulo `auth` do backend (branches em 85.71% por artefato de `__decorate` do TS — threshold pinned).
- [x] Todos os 41 arquivos de teste (mobile + backend) seguem `.ai_docs/testing_strategy.md`.

## Logs de Execução

### Revisão inicial — elenco de problemas

Consolidado a partir da auditoria do código existente:

**Mobile (13 itens):**
1. Validação de e-mail só checava vazio (não regex)
2. Validação de senha só checava vazio (sem tamanho mínimo)
3. Checkbox "Lembrar deste dispositivo" sem efeito (estado escrito mas nunca lido)
4. "Esqueceu a senha?" com `// TODO: password recovery flow` — feature não implementada mas exposta clicável
5. "Contate o Administrador" estilizado como link mas não clicável
6. Rodapé PRIVACIDADE/TERMOS/SUPORTE puramente decorativo
7. Faltavam `autofillHints` (`AutofillHints.email`/`password`) — quebra gerenciadores de senha
8. Faltavam `textInputAction` + `onFieldSubmitted` — Enter no teclado não avançava/submetia
9. Cores hardcoded espalhadas (`0xFF37628A`, `0xFFE3E9EE`, etc.) ignorando `AppTheme`
10. Strings em PT hardcoded (sem `intl`/`l10n`) — pular i18n por enquanto
11. Logo sem `Semantics`/`tooltip`
12. `churchSelection` no listener desestruturava `selectionToken` e `churches` mas descartava
13. Router expunha `/register` mas a tela de login não tinha link para ele

**Backend (8 itens):**
- B1 (CRÍTICO) `JWT_SECRET` caía em fallback `'secretKey'` — alguém pode forjar tokens
- B2 (CRÍTICO) JWT expirava em 60m sem refresh — viola "ficar sempre logado"
- B3 (CRÍTICO) Router mobile sempre iniciava em `/login`, ignorando token salvo
- B4 (ALTA) `'No active membership found'` revelava existência de usuário
- B5 (ALTA) Mensagens de erro em inglês expostas no UI
- B6 (ALTA) Email não normalizado (case-sensitive lookup)
- B7 (ALTA) Sem rate-limit específico em `/auth/login`
- B8 (ALTA) Mismatch de validação (backend `MinLength(6)`, mobile sem validação)

### Execução por fases

#### Phase 1 — Baseline de testes (TDD)
- **Criados:** `test/features/auth/cubit/auth_cubit_test.dart` (17 testes), `test/features/auth/data/auth_repository_test.dart` (16 testes)
- **Implementado:** `_translateDioException()` no `AuthRepository` — mapa `_ptBrErrorMessages` com tradução de mensagens conhecidas (`'Invalid credentials'` → `'Credenciais inválidas'`, `'No active membership found'` → `'Credenciais inválidas'` (anti-enumeration), `'Invalid or expired selection token'` → `'Sessão expirada. Faça login novamente.'`, etc.) + handlers especiais para connectivity errors (timeout/connectionError → `'Sem conexão. Verifique sua internet.'`) e 5xx (`'Erro no servidor. Tente novamente.'`).

#### Phase 2 — Gaps de teste do `LoginPage`
- Adicionados: validação de senha vazia, e-mail trimado antes de enviar, botão desabilitado durante loading, senha inicia oculta, navegação para `/home` (authenticated) e `/select-church` (churchSelection) via GoRouter de teste.
- Helper novo `buildRoutedSubject()` com placeholders das rotas de destino.

#### Phase 3 — Remoção de UI enganosa
- Removidos do `login_page.dart`: `Checkbox` "Lembrar deste dispositivo" + state `_rememberDevice`, link "Esqueceu a senha?" (TODO), TextSpan estilizado como link "Contate o Administrador", rodapé PRIVACIDADE/TERMOS/SUPORTE.
- Substituído por: texto informativo plano "Não tem uma conta?" (depois evoluído na fase final para link real, ver abaixo).

#### Phase 4 — Validação alinhada (mobile ↔ backend)
- Adicionado `_kEmailRegex` (RFC-5322-ish) → mensagem `'E-mail inválido'`
- Adicionado `_kPasswordMinLength = 6` → mensagem `'A senha deve ter ao menos 6 caracteres'` (alinhado com `LoginDto.@MinLength(6)` do backend)

#### Phase 5 — UX & Acessibilidade
- `autofillHints: [AutofillHints.email]` no campo e-mail e `[AutofillHints.password]` no campo senha
- `textInputAction.next` no e-mail + `onFieldSubmitted` movendo foco para o campo de senha (via `FocusScope.requestFocus(_passwordFocus)`)
- `textInputAction.done` na senha + `onFieldSubmitted: (_) => _submit()` (Enter submete)
- `Semantics(label: 'Logo Atos Logos', image: true)` no Container do logo

#### Phase 6 — Tokens de tema
- Substituídas todas as cores hex/sombras/raios hardcoded por referências a `AppTheme.primary`, `AppTheme.surfaceContainerHigh`, `AppTheme.cardShadow`, `AppTheme.buttonShadow`, `AppTheme.radiusLg`, etc.
- Zero `Color(0xFF...)` literal no `login_page.dart` após o refactor.

#### Phase 7 — Backend security fixes
- **Novo:** `src/common/config/env.config.ts` com `getJwtSecret()` (rejeita vazio em qualquer ambiente; rejeita `'secretKey'`, `'changeme'`, `'your-secret-key-here'`, `'secret'` e secrets <32 chars em produção) + `assertRequiredEnv()` chamado no `bootstrap()` do `main.ts`.
- **Novo:** `src/common/config/env.config.spec.ts` (8 testes cobrindo cada caminho de validação).
- `main.ts`: adicionado `import 'dotenv/config'` no topo (antes de qualquer módulo) + `transform: true` no `ValidationPipe` para ativar `@Transform`.
- `auth.module.ts`: `JwtModule.registerAsync({ useFactory: () => ({ secret: getJwtSecret() }) })`.
- `jwt.strategy.ts`: lê `secretOrKey` via `getJwtSecret()` (sem fallback).
- `auth.service.ts`: nova função `normalizeEmail(email)` aplicada em `login()` e `signupAdmin()`. Mudança da exceção `'No active membership found'` → `'Invalid credentials'` (anti-enumeration). Backend agora chama `prisma.user.findUnique({ where: { email: normalizeEmail(rawEmail) }})`.
- `login.dto.ts` e `signup-admin.dto.ts`: adicionado `@Transform(({ value }) => typeof value === 'string' ? value.trim().toLowerCase() : value)` no campo `email` (defense-in-depth).
- `auth.controller.ts`: `@Throttle({ default: { limit: 5, ttl: 60_000 }})` em `/login` e `/signup-admin`; `@Throttle({ default: { limit: 10, ttl: 60_000 }})` em `/select-church`.
- `.env.example`: documentado JWT_SECRET strong (`openssl rand -base64 48`), gates de rejeição em produção, `NODE_ENV` example.

#### Phase 7B — Refresh token com rotação e detecção de reuso

**Backend:**
- Nova model Prisma `RefreshToken` (`tokenHash` único, `userId`, `churchId`, `branchId`, `role`, `expiresAt`, `revokedAt`, `replacedById`) com FK `onDelete: Cascade` para `User`.
- Migration SQL em `prisma/migrations/20260409_add_refresh_tokens/migration.sql`.
- Helper privado `issueTokenPair(userId, email, churchId, branchId, role)` no `AuthService`: gera access JWT (60m) + refresh opaco via `crypto.randomBytes(48).toString('base64url')`. **Persiste apenas o SHA-256 do refresh** — plaintext nunca toca o DB.
- `login()` e `selectChurch()` agora retornam `{ access_token, refresh_token }`.
- **Novo método** `AuthService.refresh(rawToken)`: valida hash → se row revogada → **revoga TODAS as sessões ativas do user** (reuse detection) → senão valida expiração → emite novo par → marca old `revokedAt = now()` + `replacedById` apontando para a nova row.
- **Novo método** `AuthService.logoutRefresh(rawToken)`: revoga single device (idempotente, no-op em token desconhecido).
- Novo DTO `RefreshDto` (apenas `refreshToken: string` validado).
- Novo endpoint `POST /auth/refresh` (throttle 20/min) e `POST /auth/logout` (`@HttpCode(204)`).
- TTL do refresh token: 30 dias (constante `REFRESH_TOKEN_TTL_DAYS`).

**Mobile:**
- `AuthResponse` freezed atualizado para incluir `refreshToken` (required).
- Novas chaves `kAccessTokenKey = 'access_token'` e `kRefreshTokenKey = 'refresh_token'` no `AuthRepository`.
- `AuthRepository._persistTokens(response)` salva ambos no `flutter_secure_storage`.
- Novo método `AuthRepository.refresh()`: lê token persistido → POST `/auth/refresh` → persiste novo par → retorna `AuthResponse`. Em qualquer falha, **limpa ambos os tokens** (`_clearTokens()`) e lança `AuthException`.
- `AuthRepository.logout()` agora chama backend `/auth/logout` (best-effort, swallow `DioException` se offline) e sempre limpa tokens locais.
- `AuthInterceptor` refatorado:
  - Aceita um `_refreshDio` (Dio separado sem interceptor) para evitar recursão.
  - Pula `_kAuthPaths` (`/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/signup-admin`, `/auth/select-church`) ao anexar Authorization.
  - Em 401 de endpoint protegido: chama `/auth/refresh` no `_refreshDio` → persiste novo par → **retry da request original** com o token novo via `_refreshDio.fetch(retryOptions)`.
  - Marker `kAuthRetryMarker` em `RequestOptions.extra` previne loops infinitos (retry só 1x).
  - Refresh falha → limpa tokens e propaga o 401 original.
- `DioClient`: cria duas instâncias — `dio` (com `AuthInterceptor`) e `refreshDio` (sem). Os dois compartilham o mesmo `BaseOptions`.
- `AuthCubit.checkAuthStatus()` enriquecido: se token persistido existe, tenta refresh; sucesso → emite `authenticated`; falha → silencioso (router redireciona).
- `main.dart`: `BlocProvider(create: (_) => getIt<AuthCubit>()..checkAuthStatus())` — refresh silencioso no boot.
- Novo `lib/core/navigation/auth_redirect.dart` com função pura `resolveAuthRedirect({ currentPath, isAuthenticated })` (testável sem widget tree). `appRouter` agora tem `redirect` que delega para essa função após `getIt<AuthRepository>().isAuthenticated()`.

#### Compliance audit + correções (`.ai_docs/testing_strategy.md`)

Auditoria de 41 arquivos de teste (12 backend + 29 mobile) contra a estratégia. Resultados:

- **Phase A — Limpeza estrutural (mobile):**
  - Deletado `test/widget_test.dart` (duplicata legada do `auth_cubit_test.dart`)
  - Movidos 7 cubit tests do layout flat (`test/<feature>_cubit_test.dart`) para `test/features/<feature>/cubit/<feature>_cubit_test.dart`: positions, events, visitors, ebd, financial, home, members.

- **Phase B — Renomes (TDD/BDD naming):**
  - Backend: renomeados/reorganizados testes em `app.controller.spec.ts` (`describe('AppController - getHello')`), `jwt-auth.guard.spec.ts` (mergeou 2 triviais em 1 com contexto), `jwt.strategy.spec.ts` (split em `describe('constructor')` + `describe('validate')`), `events.service.spec.ts` (removido `should be defined`, describe renomeado para `EventsService - findAll`), `app.e2e-spec.ts`. Todos os testes ganharam comentários `// Given / // When / // Then`.
  - Mobile: 4 testes do `register_page_test.dart` renomeados com contexto behavioral; `members_cubit_test.dart` `group('MembersCubit search')` → `group('MembersCubit - search')`.

- **Phase C — Gaps de interação preenchidos (mobile):**
  - `dashboard_page_test.dart` (4 → 6 testes): adicionado teste de error state (renderiza mensagem + botão retry, retry chama `HomeCubit.loadDashboard`).
  - `create_member_page_test.dart` (5 → 10 testes): empty submit → `'Informe o nome'`, valid form → pop, back button → pop, accordion toggle, valid submit não mostra erro.
  - `edit_profile_page_test.dart` (3 → 9 testes): pre-fill com profile do auth, submit forwarda valores trimados para `ProfileCubit.updateMyProfile`, botão desabilitado durante saving, snackbar de erro, snackbar de sucesso.

- **Phase D — Edge cases (backend):**
  - `events.service.spec.ts`: novos testes `should return an empty page shape when no events exist for the tenant` e `should honour the requested page and limit in the Prisma query` (verifica `skip`/`take`).

#### Coverage closure final (mobile login flow)

Após a auditoria, execução de `flutter test --coverage` + parsing de `lcov.info` filtrando apenas os arquivos do fluxo de login. Identificados gaps e fechados via TDD:

- **Novo:** `test/features/auth/domain/models/auth_models_test.dart` (7 testes) — fromJson round-trips para `LoginRequest`, `SelectChurchRequest`, `AuthResponse`, `ChurchOption`, `UserProfile` (full payload + minimal payload com profile null e positions vazia).
- **Novo:** `test/core/network/dio_client_test.dart` (3 testes) — base URL/timeouts, interceptor anexado, singleton identity.
- **Novo:** `test/core/navigation/app_router_test.dart` ganhou +3 testes — `initialLocation` é `/login`, lista de rotas contém todas as públicas, widget test que pumpa o `appRouter` real e renderiza `LoginPage` no cold start de usuário não-autenticado (cobre o `redirect` callback + builder `/login`).
- **Novo teste em `login_page_test.dart`:** `should advance focus to the password field when "next" is pressed on the email keyboard` (cobre `onFieldSubmitted` do email).
- **Novo teste em `register_page_test.dart`:** mismatch quando confirm-password vazio.

**Ferramenta criada:** `tool/coverage_login.js` (Node script) — filtra `coverage/lcov.info` para os arquivos do fluxo de login, aplica um mapa de exclusões documentadas (com razão por linha), imprime tabela por arquivo + total + lista de exclusões. Uso: `flutter test --coverage && node tool/coverage_login.js`.

#### Última iteração — CTA de cadastro

Após os 100% de coverage, durante teste manual o usuário identificou:
- **Falta de CTA para `/register`** na tela de login. O texto antigo `"Não tem uma conta? Contate o administrador da sua igreja."` era informativo e não permitia que admins de novas igrejas iniciassem o fluxo de signup.
- **Solução:** adicionado `Text.rich` com `TextSpan` "Não tem uma conta? " seguido de outro `TextSpan` "Cadastre sua igreja" estilizado em `AppTheme.primary` bold, com `TapGestureRecognizer` invocando `context.go('/register')`.
- **Bug visual** detectado em sequência: a primeira implementação usou `WidgetSpan(GestureDetector(Text))`, que faz o link ficar levemente acima do baseline do texto pai. **Refatorado** para `TextSpan(recognizer: TapGestureRecognizer)` puro — alinhamento perfeito porque agora é tudo texto.
- `_LoginPageState` ganhou `late final TapGestureRecognizer _signupTapRecognizer`, criado em `initState` e disposto em `dispose` (lifecycle correto).
- Testes: novo teste de Layout que valida o `RichText.text.toPlainText() == 'Não tem uma conta? Cadastre sua igreja'` E que o span "Cadastre sua igreja" carrega um `TapGestureRecognizer`. Novo teste de Navigation que dispara o recognizer programaticamente (via helper `tapInlineLink`) e verifica que o router transitou para `/register`.
- Helpers de teste novos: `findRichTextContaining(substring)` e `tapInlineLink(tester, linkText)` em `login_page_test.dart` (reusáveis para futuros testes de inline links).

## Decisões Técnicas

### Por que refresh token com rotação + reuse detection

- **JWT short-lived (60m)** dá janela curta de exploração se um access_token vazar.
- **Refresh opaco long-lived (30d)** + persistido só como SHA-256 → mesmo um dump do DB não vaza tokens.
- **Rotação a cada uso** transforma todo refresh em "single-use". Permite **detectar reuso**: se um refresh já revogado é apresentado, alguém o usou após nós (token foi clonado). Resposta defensiva: revoga TODAS as sessões ativas do usuário, forçando re-login.
- A coluna `replacedById` mantém uma trilha de rotação para auditoria forense.

### Por que tradução PT-BR no client (não no backend)

- Mantém o backend i18n-friendly: ele continua emitindo `'Invalid credentials'`. Outros clients (ex.: dashboard web no futuro) podem traduzir para outros idiomas sem mudança no servidor.
- O mapa `_ptBrErrorMessages` no `AuthRepository` fica explícito e fácil de revisar.

### Por que `app_router.dart` tem 19 linhas excluídas

São os builders das rotas para telas que não fazem parte do fluxo de login (`/home`, `/secretaria`, `/create-member`, `/member-profile/:id`, `/edit-profile`, `/edit-member/:id`, `/branches`, `/create-branch`, `/coming-soon`). Essas linhas serão cobertas quando auditarmos os fluxos correspondentes. A LÓGICA do redirect (em `auth_redirect.dart`) tem 100% de coverage e o builder de `/login` é exercido pelo widget test do `appRouter`.

### Por que `dio_client.dart:42` está excluído

A closure `logPrint: (obj) => debugPrint(obj.toString())` só é invocada pelo Dio runtime em uma round-trip HTTP real, em builds debug. Não é lógica de login — é instrumentação de dev.

### Por que `auth.controller.ts` aceita 75% de branch coverage

O ts-jest emite `__decorate` helpers para cada decorator, e cada um inclui um ternário `typeof Reflect.decorate === 'function' ? ... : null`. O ramo `null` é inalcançável em runtime (Reflect sempre existe no Node). Tentativas: `/* istanbul ignore next */` (não sobrevive ao TS→JS), `coverageProvider: 'v8'` (piora), `importHelpers: true` (sem efeito). Solução pragmática: `coverageThreshold` específico do arquivo pinned em 75% — qualquer regressão real (deletar um teste, remover uma assertion) quebra o build.

### Por que `TextSpan + TapGestureRecognizer` em vez de `WidgetSpan + GestureDetector`

`WidgetSpan` embeda um widget no fluxo de texto, mas o widget não compartilha o baseline alphabetic do texto pai por padrão — fica visualmente "elevado". A solução idiomática Flutter para inline tappable text é `TextSpan` com `recognizer`, que mantém o baseline perfeito (é o mesmo `RenderParagraph`).

### Por que removemos `widget_test.dart`

Era uma duplicata legada do `auth_cubit_test.dart` com menos cobertura e usando `isA<AuthState>().having()` com `maybeWhen` complexo (legibilidade inferior). Os 5 testes que tinha já estavam contemplados (e melhor escritos) no arquivo canônico.

## Arquivos criados / modificados

### Backend

| Ação | Arquivo |
|---|---|
| Novo | `src/common/config/env.config.ts` |
| Novo | `src/common/config/env.config.spec.ts` |
| Novo | `src/modules/auth/auth.controller.spec.ts` |
| Novo | `src/modules/auth/jwt.strategy.spec.ts` |
| Novo | `src/modules/auth/jwt-auth.guard.spec.ts` |
| Novo | `src/modules/auth/auth.module.spec.ts` |
| Novo | `src/modules/auth/dto/dto.spec.ts` |
| Novo | `src/modules/auth/dto/refresh.dto.ts` |
| Novo | `prisma/migrations/20260409_add_refresh_tokens/migration.sql` |
| Mod | `prisma/schema.prisma` (model `RefreshToken` + relação no `User`) |
| Mod | `src/main.ts` (`dotenv/config` + `assertRequiredEnv()` + `transform: true`) |
| Mod | `src/modules/auth/auth.module.ts` (`JwtModule.registerAsync` + `getJwtSecret()`) |
| Mod | `src/modules/auth/auth.service.ts` (`normalizeEmail`, `issueTokenPair`, `refresh`, `logoutRefresh`, `hashRefreshToken`) |
| Mod | `src/modules/auth/auth.service.spec.ts` (refresh tests, reuse detection, normalize, info-leak fix) |
| Mod | `src/modules/auth/auth.controller.ts` (`@Throttle` por endpoint, `/refresh` e `/logout` endpoints) |
| Mod | `src/modules/auth/jwt.strategy.ts` (`getJwtSecret()`) |
| Mod | `src/modules/auth/dto/login.dto.ts` (`@Transform` lowercase + trim) |
| Mod | `src/modules/auth/dto/signup-admin.dto.ts` (`@Transform`) |
| Mod | `src/modules/events/events.service.spec.ts` (renames + edge cases) |
| Mod | `src/app.controller.spec.ts` (rename + GWT comments) |
| Mod | `src/modules/auth/auth.controller.ts` (rate-limit decorators) |
| Mod | `test/app.e2e-spec.ts` (rename + GWT) |
| Mod | `package.json` (`coverageThreshold` por arquivo) |
| Mod | `tsconfig.json` (`importHelpers: true`) |
| Mod | `.env.example` (JWT_SECRET hardening docs) |
| Mod | `.gitignore` (set padrão NestJS: `coverage/`, `dist/`, `*.log`, `.env.*`, etc.) |

### Mobile

| Ação | Arquivo |
|---|---|
| Novo | `lib/core/navigation/auth_redirect.dart` |
| Novo | `test/features/auth/cubit/auth_cubit_test.dart` |
| Novo | `test/features/auth/data/auth_repository_test.dart` |
| Novo | `test/features/auth/domain/models/auth_models_test.dart` |
| Novo | `test/core/network/auth_interceptor_test.dart` |
| Novo | `test/core/network/dio_client_test.dart` |
| Novo | `test/core/navigation/app_router_test.dart` |
| Novo | `tool/coverage_login.js` (coverage report tool com exclusões documentadas) |
| Mod | `lib/features/auth/data/auth_repository.dart` (refresh, logout backend, PT-BR mapping, persist both tokens) |
| Mod | `lib/features/auth/domain/models/auth_response.dart` (added `refreshToken`) |
| Mod | `lib/features/auth/presentation/cubit/auth_cubit.dart` (`checkAuthStatus` tries refresh) |
| Mod | `lib/features/auth/presentation/pages/login_page.dart` (validation, UX, theme tokens, signup CTA, removed misleading UI) |
| Mod | `lib/core/network/auth_interceptor.dart` (refactor: 401 retry via separate refreshDio) |
| Mod | `lib/core/network/dio_client.dart` (creates refreshDio and main dio) |
| Mod | `lib/core/navigation/app_router.dart` (`redirect` delegating to `resolveAuthRedirect`) |
| Mod | `lib/main.dart` (`..checkAuthStatus()` no boot) |
| Mod | `test/features/auth/pages/login_page_test.dart` (ampla expansão, 26 testes) |
| Mod | `test/features/auth/pages/register_page_test.dart` (renames + edge cases) |
| Mod | `test/features/home/pages/dashboard_page_test.dart` (error state) |
| Mod | `test/features/members/pages/create_member_page_test.dart` (interactions) |
| Mod | `test/features/profile/pages/edit_profile_page_test.dart` (submit/states) |
| Mod | `test/features/members/cubit/members_cubit_test.dart` (group rename) |
| Del | `test/widget_test.dart` (duplicata) |
| Mov | 7 cubit tests do flat layout para `test/features/<feature>/cubit/` |

## Resultado dos Testes

### Mobile

```
$ flutter test
00:17 +208: All tests passed!
```

```
$ flutter test --coverage && node tool/coverage_login.js

Login Flow — Mobile Coverage Report
==========================================================================================================
File                                                                   Covered    Excluded         Status
----------------------------------------------------------------------------------------------------------
lib/core/error/exceptions.dart                                    5/5 (100.0%)           -         ✓ 100%
lib/core/navigation/app_router.dart                             19/19 (100.0%)          19         ✓ 100%
lib/core/navigation/auth_redirect.dart                            3/3 (100.0%)           -         ✓ 100%
lib/core/network/auth_interceptor.dart                          41/41 (100.0%)           -         ✓ 100%
lib/core/network/dio_client.dart                                  9/9 (100.0%)           1         ✓ 100%
lib/features/auth/data/auth_repository.dart                     80/80 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/auth_response.dart                2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/church_option.dart                2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/login_request.dart                2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/select_church_request.dart        2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/user_profile.dart               14/14 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/cubit/auth_cubit.dart            42/42 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/pages/login_page.dart          122/122 (100.0%)           -         ✓ 100%
----------------------------------------------------------------------------------------------------------
TOTAL (login flow, excl. documented skips)                    343/343 (100.0%)          20
```

**Exclusões documentadas:**
- `dio_client.dart:42` — closure `LogInterceptor.logPrint` debug-only.
- `app_router.dart` (19 linhas) — route builders das telas fora do fluxo de login.

### Backend

```
$ npx jest
Test Suites: 11 passed, 11 total
Tests:       89 passed, 89 total
```

```
$ npx jest --coverage  (módulo auth)
src/modules/auth                 |     100 |    85.71 |     100 |     100
  auth.controller.ts             |     100 |       75 |     100 |     100   ← decorator metadata
  auth.module.ts                 |     100 |      100 |     100 |     100
  auth.service.ts                |     100 |    94.73 |     100 |     100   ← constructor param decorator metadata
  jwt-auth.guard.ts              |     100 |      100 |     100 |     100
  jwt.strategy.ts                |     100 |      100 |     100 |     100
src/modules/auth/dto             |     100 |      100 |     100 |     100
src/common/config                |     100 |      100 |     100 |     100
```

**Thresholds enforced** via `package.json` `coverageThreshold` por arquivo. Branches sub-100% nos 2 arquivos acima são exclusivamente artefatos do `__decorate` do TypeScript (ternários sobre `Reflect`), documentados.

### Total de testes

- **Mobile:** 143 → **208** (+65)
- **Backend:** ~40 → **89** (+49)
- **Soma:** ~183 → **297** (+114)

## Como verificar / executar

### Pré-requisitos

**Backend (`atos-logos-backend/`):**

1. Gerar e configurar `JWT_SECRET` forte no `.env`:
   ```bash
   openssl rand -base64 48
   # cole o resultado em JWT_SECRET=...
   ```

2. Rodar a migration do refresh token:
   ```bash
   npx prisma migrate dev
   ```

3. Subir o servidor:
   ```bash
   npm run start:dev
   ```

   ⚠️ Se `JWT_SECRET` estiver vazio, for um default fraco (`secretKey`, `changeme`, etc.), ou tiver < 32 chars em produção, o servidor **falha no boot** com mensagem clara — comportamento esperado.

**Mobile (`atos_logos_mobile/`):**

1. Verificar `lib/core/constants/api_constants.dart` aponta para o backend correto.
2. Rodar:
   ```bash
   flutter run
   ```

### Comandos de verificação

**Mobile:**
```bash
# Testes
flutter test

# Coverage do fluxo de login
flutter test --coverage && node tool/coverage_login.js

# Análise estática
flutter analyze
```

**Backend:**
```bash
# Testes
npx jest

# Coverage
npx jest --coverage

# Build
npx nest build
```

### Checklist de teste manual (smoke)

**Happy path:**
- Abrir o app sem sessão → cai em `/login`
- Login com credenciais válidas → `/home`
- Matar o app e reabrir → mantém autenticado (boot-time refresh) → vai direto para `/home`
- User multi-igreja → cai em `/select-church` após login → seleção → `/home`

**Validação client-side:**
- E-mail vazio → "Informe o e-mail"
- E-mail malformado → "E-mail inválido"
- Senha vazia → "Informe a senha"
- Senha < 6 chars → "A senha deve ter ao menos 6 caracteres"

**Erros do backend (PT-BR):**
- Credenciais erradas → snackbar "Credenciais inválidas"
- Backend desligado → "Sem conexão. Verifique sua internet."
- 500 → "Erro no servidor. Tente novamente."

**Rate limit:**
- 5 tentativas erradas em < 1 min → 6ª retorna 429

**Refresh:**
- Logar → `access_token` E `refresh_token` no secure storage
- Após access expirar (alterar JWT expiry para `60s` temporariamente) → próxima request triggers refresh transparente + retry
- Logout → revoga refresh no backend + limpa locals

**UX:**
- Tab no e-mail → foco vai pra senha
- Enter na senha → submete
- Olho da senha alterna ver/ocultar
- Gerenciador de senha do device oferece autofill
- Link "Cadastre sua igreja" leva pra `/register`
- Não existe checkbox "Lembrar dispositivo" nem link "Esqueceu a senha?"

**Navegação / redirect:**
- Sem token + tentar rota protegida → redirect `/login`
- Com token + tentar `/login` manual → redirect `/home`

## Próximos passos

1. **Refresh token rotation observability**: hoje, em uma detecção de reuso, o backend revoga todas as sessões silenciosamente. Adicionar log estruturado / alerta para investigação futura.
2. **"Esqueceu a senha?"** ficou removido. Quando for implementar, vai ser ticket separado: precisa endpoint `/auth/forgot-password`, email service (Resend, SES, etc.), reset token de uso único, página mobile.
3. **Auditoria das outras telas** (`select-church`, `register`, `home`, etc.) seguindo o mesmo padrão deste TCK.
4. **Switch para `@swc/jest`** se quisermos eliminar os artefatos de `__decorate` e bater 100% de branches no backend (épico opcional).
