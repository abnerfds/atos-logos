# [Done] TCK-006: Revisão completa do Fluxo Select-Church (Mobile)

## Descrição

Revisão visual + técnica da tela `/select-church` (segundo passo do login quando o usuário tem múltiplas memberships ativas) seguindo o mesmo padrão dos TCK-004 (login) e TCK-005 (register).

Escopo:
1. **Redesenho** da UI para o novo layout "Escolha sua comunidade" (mock de 2026-04-11):
   - Eyebrow label "BEM-VINDO DE VOLTA"
   - Headline grande "Escolha sua comunidade"
   - Lista de cards por igreja (ícone + nome + role localizado + chevron)
   - Card "REFLEXÃO DO DIA" ao final com verso bíblico + atribuição + autor/ministério
2. **Cobertura**: a tela anterior não tinha nenhum teste de widget — criamos do zero.
3. **Flow infrastructure já estava pronta** (TCK-004/005): `AuthCubit.selectChurch`, `AuthRepository.selectChurch`, DTO backend, rate-limit, refresh token rotation. Sem mudança nessa camada.

## Critérios de Aceite

- [x] Tela exibe "BEM-VINDO DE VOLTA" + "Escolha sua comunidade" exatamente como o mock.
- [x] Cada membership ativa vira um card com nome da igreja + role localizado (`Admin` / `Secretário` / `Membro`).
- [x] **Mesmo ícone (`Icons.church_rounded`)** em todos os cards — decisão explícita do usuário (simplicidade visual).
- [x] Tap em qualquer card chama `AuthCubit.selectChurch(churchId)` com o id correto.
- [x] Estado `loading` mostra `CircularProgressIndicator`.
- [x] Estado `error` mostra snackbar com a mensagem do backend (já traduzida PT-BR pelo TCK-004).
- [x] Transição para `authenticated` redireciona para `/home`.
- [x] Card "REFLEXÃO DO DIA" exibe verso + referência + autor/ministério (hardcoded placeholder com TODO backend).
- [x] Widget `DailyReflectionCard` extraído com campos via construtor — futuro endpoint só precisa alterar o call site, não a widget.
- [x] **100% de cobertura no fluxo de select-church** (mobile), zero exclusões documentadas.
- [x] Sem regressão nos fluxos de login (339/339) e registro (333/333).
- [x] Analyzer limpo em `lib/features/auth` e `test/features/auth`.

## Logs de Execução

### Revisão inicial

O arquivo `church_selection_page.dart` já existia com um layout funcional (herdado de uma sessão anterior) — basicamente um dialog-card central com título genérico e cards simples. Sem testes de widget.

A revisão consistiu em dois pedaços independentes:

1. **UI rework** para o novo mock fornecido pelo usuário
2. **Primeira passada de testes** do zero (TDD RED → GREEN)

### Decisões de escopo (antes de codar)

Apresentadas e confirmadas:

| # | Item | Decisão final |
|---|---|---|
| 1 | Termo no título | **"Escolha sua comunidade"** (mantém o do mock) |
| 2 | Ícones diferentes por card | **Mesmo ícone pra todos** (`Icons.church_rounded`) — simplicidade |
| 3 | Card "REFLEXÃO DO DIA" | **Hardcode** com verso do mock + TODO backend |
| 4 | Autor da reflexão | **Hardcode** (Pr. Ricardo Santos / Ministério de Ensino) como placeholder |

### Execução — Phase A (TDD: RED)

**Novo arquivo**: `test/features/auth/pages/church_selection_page_test.dart`.

14 testes organizados em 5 groups seguindo `.ai_docs/testing_strategy.md`:

- **Layout (6)**: eyebrow "BEM-VINDO DE VOLTA", headline "Escolha sua comunidade", um card por igreja, labels de role localizados (Admin / Secretário / Membro), mesmo ícone em todos os cards, chevron em cada linha
- **Daily Reflection (3)**: label "REFLEXÃO DO DIA", verso + referência hardcoded, autor + ministério hardcoded
- **Interactions (2)**: tap no card chama `selectChurch(id)` com o id correto (dois cards diferentes pra garantir que não é um hardcode acidental)
- **States (2)**: loading indicator, error snackbar via `whenListen`
- **Navigation (1)**: `authenticated` redireciona para `/home` via GoRouter de teste

Helpers:
- `buildSubject()` — pump simples com `MockAuthCubit` fixo em `churchSelection` com 3 igrejas sample (`ADMIN`, `SECRETARY`, `MEMBER`)
- `buildRoutedSubject()` — pump com real `GoRouter` pra validar o `context.go('/home')` do listener

Rodar → **7/14 PASS, 7/14 FAIL** (RED esperado).

### Execução — Phase B (GREEN)

Reescrita completa de `lib/features/auth/presentation/pages/church_selection_page.dart`:

- `ChurchSelectionPage` (StatelessWidget) dividida em sub-widgets privados pra legibilidade:
  - `ChurchSelectionPage` — Scaffold + BlocConsumer
  - `_ChurchSelectionBody` — layout principal (ConstrainedBox + SingleChildScrollView)
  - `_Header` — eyebrow + headline
  - `_ChurchCard` — card individual de igreja (Material + InkWell + Container + Row)
  - `DailyReflectionCard` — card público de reflexão (único widget exportado além da página)
- `_ChurchCard._roleLabel()` mapeia `Role` (enum backend) → string PT-BR:
  - `ADMIN` → `'Admin'`
  - `SECRETARY` → `'Secretário'`
  - `MEMBER` → `'Membro'`
  - Fallback: retorna o próprio valor (defensivo se o backend ganhar uma role nova)
- Theme tokens em tudo (`AppTheme.surface`, `AppTheme.surfaceContainerLowest`, `AppTheme.secondaryContainer`, `AppTheme.primary`, `AppTheme.onSurface`, `AppTheme.onSurfaceVariant`, `AppTheme.outline`, `AppTheme.radiusLg/Md`)
- `DailyReflectionCard`:
  - Recebe `verse`, `reference`, `authorName`, `authorRole` via construtor
  - Renderiza label pequeno + verso italic + attribution + divider + author row (CircleAvatar placeholder + nome + ministério)
  - TODO explícito no docstring mencionando o endpoint futuro `/reflections/today`
- Container do card de igreja usa `Border.all(color: AppTheme.surfaceContainerLow)` ao invés de só elevation → bate com o mock (borda fina, sem sombra pesada)

Rodar → **14/14 GREEN**.

### Execução — Phase C (coverage tool + regressão)

**Novo arquivo**: `tool/coverage_select_church.js`.

Mesma arquitetura dos outros dois coverage tools do auth (`coverage_login.js`, `coverage_register.js`):
- Filtra `coverage/lcov.info` pelos arquivos do fluxo de select-church
- Mapa de exclusões documentadas (vazio hoje — nenhuma linha provably uncoverable)
- Tabela por arquivo + total

Arquivos trackeados:
- `lib/features/auth/presentation/pages/church_selection_page.dart` — alvo principal
- `lib/features/auth/domain/models/church_option.dart`
- `lib/features/auth/domain/models/select_church_request.dart`
- `lib/features/auth/presentation/cubit/auth_cubit.dart` (compartilhado)
- `lib/features/auth/data/auth_repository.dart` (compartilhado)
- `lib/features/auth/domain/models/auth_response.dart` (compartilhado)
- `lib/core/error/exceptions.dart` (compartilhado)

Rodar → **232/232 linhas (100%)** no fluxo. Sem exclusões.

Regressão:
- Login flow → 339/339 (100%), 20 exclusões documentadas (inalterado)
- Register flow → 333/333 (100%), 0 exclusões (inalterado)
- Suite completa → **272/272 testes** (de 258 antes, +14 do church_selection)
- `flutter analyze lib/features/auth test/features/auth` → No issues found

## Decisões Técnicas

### Por que o mesmo ícone pra todos os cards

Opção explícita do usuário. Alternativas consideradas:
- **Por role** (ADMIN → igreja, SECRETARY → prédio, MEMBER → pin) — seria visualmente mais rico, mas introduz semântica não documentada (por que "líder" é um prédio?) e o backend não retorna essa distinção como um campo estruturado.
- **Por posição** (1° igreja, 2° prédio, 3° pin como o mock literal) — não escalável pra 4+ memberships.

O ícone único reduz complexidade visual, é consistente, e o card fica dependente apenas do conteúdo textual (nome + role). Se no futuro o backend retornar algo como `branchType: 'HQ' | 'FILIAL'`, o mapeamento ícone-por-tipo fica trivial.

### Por que `DailyReflectionCard` aceita conteúdo via construtor mesmo sendo hoje hardcoded

Separação de responsabilidades. A widget não sabe NADA sobre onde o conteúdo vem — ela só renderiza o que recebe. O call site em `_ChurchSelectionBody` é o único lugar que hoje hardcoda placeholder. Quando o endpoint `/reflections/today` existir, a substituição é trivial — basta envolver a chamada num BlocBuilder e alimentar os parâmetros com o `state.reflection`. Nada na widget muda.

### Por que o teste de navegação pra `/home` usa um GoRouter real em vez de mockar `context.go`

Mesmo padrão adotado no `login_page_test.dart` e no `register_page_test.dart`: o `BlocListener` chama `context.go('/home')`, que é uma extension do go_router. Mockar o Router diretamente (via test double de `GoRouter`) é frágil e não testa a integração real. Em vez disso, o helper `buildRoutedSubject()` monta um `MaterialApp.router` com um mini-router com placeholders (`/select-church` e `/home`). O teste então pumpa, emite o estado `authenticated` via `whenListen`, e assert que o placeholder `HOME_ROUTE` ficou visível — prova que a navegação real aconteceu.

### Por que as strings de roles são hardcodadas como labels em vez de vir de um arquivo i18n

Consistência com o resto do app: nenhuma tela usa `intl`/`l10n` hoje. Quando o i18n for introduzido (ticket futuro), será um refactor de um commit fazendo `Admin` → `context.l10n.roleAdmin` em todas as telas. Hoje o foco é ter as strings certas e testadas num único lugar (`_ChurchCard._roleLabel`).

## Arquivos criados / modificados

### Mobile

| Ação | Arquivo |
|---|---|
| Modificado | `lib/features/auth/presentation/pages/church_selection_page.dart` (rewrite completo: sub-widgets privados, `DailyReflectionCard` público extraído, novo layout fiel ao mock) |
| Novo | `test/features/auth/pages/church_selection_page_test.dart` (14 testes, 5 groups) |
| Novo | `tool/coverage_select_church.js` (Node script de coverage per-file do fluxo) |
| Novo | `.ai_docs/tickets/TCK-006-select-church-flow-review.md` (este arquivo) |

### Backend

Nenhum arquivo backend modificado. Todo o endurecimento de `/auth/select-church` (throttle, DTO validation, token pair rotation) já foi feito no TCK-004.

## Resultado dos Testes

### Mobile

```
$ flutter test
00:23 +272: All tests passed!
```

```
$ flutter test --coverage && node tool/coverage_select_church.js

Select-Church Flow — Mobile Coverage Report
==========================================================================================================
File                                                                   Covered    Excluded         Status
----------------------------------------------------------------------------------------------------------
lib/core/error/exceptions.dart                                    5/5 (100.0%)           -         ✓ 100%
lib/features/auth/data/auth_repository.dart                     84/84 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/auth_response.dart                2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/church_option.dart                2/2 (100.0%)           -         ✓ 100%
lib/features/auth/domain/models/select_church_request.dart        2/2 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/cubit/auth_cubit.dart            42/42 (100.0%)           -         ✓ 100%
lib/features/auth/presentation/pages/church_selection_page.dart    95/95 (100.0%)           -         ✓ 100%
----------------------------------------------------------------------------------------------------------
TOTAL (select-church flow, excl. documented skips)            232/232 (100.0%)           0
```

```
$ flutter analyze lib/features/auth test/features/auth
No issues found!
```

### Regressão nos outros 2 fluxos auth

```
Login flow     — 339/339 (100.0%), 20 exclusões documentadas
Register flow  — 333/333 (100.0%), 0 exclusões
```

### Total de testes

- **Mobile**: 258 → **272** (+14 testes novos do church_selection)
- **Backend**: 88 (inalterado — nenhuma mudança backend)

## Como verificar / testar

### Pré-requisito: seed manual de um user multi-igreja

A `/select-church` só aparece para usuários com 2+ memberships ativas. Se o seu banco só tem um signup padrão, seed uma segunda membership manualmente:

1. `npx prisma studio`
2. Pegar o `id` do seu user em `User`
3. Criar uma nova `Church` (só o nome)
4. Criar uma nova `Branch` linkada à nova church (`isHeadquarters: true`)
5. Criar um novo `Membership` linkando o user existente à nova church/branch (`role: 'MEMBER'`, `status: 'ACTIVE'`)
6. Logar no app com o mesmo email → agora cai em `/select-church`

### Checklist de teste manual

- [ ] Eyebrow "BEM-VINDO DE VOLTA" e headline "Escolha sua comunidade" visíveis no topo
- [ ] Cada igreja do usuário aparece como um card separado
- [ ] Ícone `Icons.church_rounded` aparece em todos os cards (todos iguais)
- [ ] Role aparece abaixo do nome (`Admin` / `Secretário` / `Membro` dependendo)
- [ ] Chevron à direita em cada card
- [ ] Card "REFLEXÃO DO DIA" aparece abaixo da lista com verso Mateus 18:20
- [ ] Card de reflexão mostra "Pr. Ricardo Santos — Ministério de Ensino" como autor
- [ ] Tap em um card → spinner aparece → redireciona para `/home`
- [ ] Se backend retornar erro (ex: selectionToken expirado), aparece snackbar PT-BR
- [ ] Visualmente bate com o mock fornecido

## Próximos passos

1. **Fluxo auth fechado**: com TCK-004 (login), TCK-005 (register) e agora TCK-006 (select-church), todo o pacote `auth` está 100% revisado, testado e documentado.
2. **Próxima tela**: provavelmente `/home` (dashboard) — primeira experiência real do usuário pós-login.
3. **Épicos opcionais abertos pelo TCK-006**:
   - Endpoint `/reflections/today` para alimentar o `DailyReflectionCard` com dados reais
   - i18n (`intl`/`l10n`) para todas as strings dos fluxos auth (e depois do resto do app)
   - Revisar se o fluxo de "convite a membership" justifica uma UI (hoje só dá pra criar multi-igreja via seed/Prisma Studio)
