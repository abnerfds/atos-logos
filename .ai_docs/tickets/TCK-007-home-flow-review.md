# [Done] TCK-007: Revisão completa do Fluxo Home / Dashboard

## Descrição

Revisão de ponta-a-ponta do fluxo **Home** (dashboard pós-login) do `atos-logos-core`, seguindo o mesmo padrão dos tickets anteriores:

1. **Dashboard** (`dashboard_page.dart`): saudação, flip card do membro (carteira digital), carrossel de aniversariantes, lista de próximos eventos.
2. **Home shell** (`home_page.dart`): Scaffold com AppBar, Drawer, Bottom Nav, Profile Sheet — a casca que envolve o dashboard e os próximos tabs (Agenda / Notificações).
3. **HomeCubit/HomeRepository**: carregamento concorrente de church + birthdays + upcoming events com fallback parcial resiliente.
4. **Shared widgets** da home shell (`app_bar_widget`, `app_drawer`, `custom_bottom_nav`, `profile_bottom_sheet`, `coming_soon_page`): theme tokens, Semantics, correções de strings.
5. **Backend**: correção pontual na query do `getProfile` que esquecia de selecionar `baptismDate`.

## Critérios de Aceite

- [x] `HomeState.upcomingEvents` deixa de ser `List<dynamic>` e passa a ser `List<UpcomingEvent>` (freezed).
- [x] O `branch.name` do backend é mostrado como "local" do evento — antes o dashboard lia um campo `location` inexistente e caía no literal `"Local"`.
- [x] Saudação corrigida para **"Olá, [firstName]"** (antes era `"Ola"`, sem acento). Subtítulo idem: `"Que bom ter você aqui hoje."`.
- [x] Headers acentuados: `"Aniversariantes do Mês"`, `"Próximos Eventos"`, `"Informações de Registro"`, `"ADMISSÃO"`.
- [x] **Número da carteirinha real**: agora vem de `profile.profile?.registrationNumber`. Antes era `#10234` hardcoded.
- [x] **Data de batismo real**: `UserProfileDetail` ganhou `String? baptismDate`; backend `getProfile` agora seleciona `baptismDate` na query Prisma; dashboard lê `profile.profile?.baptismDate`. Antes era `"--"` hardcoded.
- [x] Datas formatadas como `dd/MM/yyyy` (brasileiro) em vez do ISO bruto `"1990-05-20"`.
- [x] **Theme tokens em tudo**: `dashboard_page`, `home_page`, `app_bar_widget`, `app_drawer`, `custom_bottom_nav`, `profile_bottom_sheet`. Zero `Color(0xFF…)` solto (exceto o verde do healthcheck — constante local documentada).
- [x] **Semantics** em botões principais: logo de menu, avatar, flip card, tabs do bottom nav.
- [x] `ProfileBottomSheet` resiliente a viewport pequeno (wrap em `SingleChildScrollView`), role mapping exaustivo (`ADMIN`, `SECRETARY`, `MEMBER`, fallback), placeholder visual quando `userName` vazio.
- [x] `HomePage` com fallback **`—`** em vez de `"Membro"`/`"MEMBER"` como texto literal quando o profile ainda não carregou.
- [x] Regra de carregamento do dashboard explicitamente documentada no `HomeCubit`: falha do `church` = erro total; falha de birthdays/events = fallback pra lista vazia (UX escolhida no D5).
- [x] **100% de cobertura** no fluxo home: **627/627 linhas**, zero exclusões documentadas.
- [x] Sem regressão nos fluxos anteriores: login 339/339, register 333/333, select-church 232/232.
- [x] Backend auth (60 testes), testes todos passando (329 mobile).
- [x] `flutter analyze` limpo nos arquivos tocados.

## Logs de Execução

### Revisão inicial — elenco

**HIGH:**
- **H1** `dashboard_page.dart:179` lia `map['location']` mas o backend nunca retorna esse campo → sempre caía no literal `"Local"`.
- **H2** Greeting `"Ola, ..."` sem acento; subtítulo `"voce"` idem; headers `"Mes"`, `"Proximos"`, etc.
- **H3** Flip card front hardcodava `#10234` como número de matrícula.
- **H4** Flip card back hardcodava `baptismDate: '--'` — o backend tinha o dado no Prisma mas não selecionava na query do `/auth/me`.
- **H5** `HomeState.loaded(..., List<dynamic> upcomingEvents)` — cast manual + parse ISO frágil no dashboard.
- **H6** Zero theme tokens no dashboard (~50 cores literais).
- **H7** Zero `Semantics` em toda a tela home (flip card, avatar, menu, bottom nav).
- **H8** `HomeCubit.loadDashboard` mascarava falhas parciais sem log.

**MED:**
- **M1** `HomePage` hardcodava `"Membro"`/`"MEMBER"` como texto literal pros casos onde `AuthCubit.fetchProfile` ainda não tinha resolvido.
- **M2-M7** Theme tokens ausentes nos 4 shared widgets (app_bar, app_drawer, bottom_nav, profile_sheet).
- **M3** `app_drawer` com status "verde/operacional" hardcoded sem healthcheck real.
- **M5** `profile_bottom_sheet` com versão `"2.4.0"` hardcoded.
- **M6** `profile_bottom_sheet` com role mapping incompleto (sem branch explícito pra `MEMBER`).
- **M8** Testes de home com gaps grandes: sem interação do drawer, sem profile sheet, sem empty states do dashboard, sem flip card integrado.
- **M9** `home_cubit` sem timeout.
- **M10** `findBirthdays` backend carrega todos os profiles em memória e filtra em JS — dívida técnica conhecida do backend.

**LOW:** `photoUrl`/`documentNumber` definidos mas não usados; animações hardcoded (200ms/600ms); ícones sem tooltips.

### Decisões de escopo (confirmadas pelo usuário)

| # | Item | Decisão |
|---|---|---|
| D1 | Abrangência | **C** — dashboard + home_page + shared widgets + backend fix |
| D2 | Campo location | **b** — usar `branch.name` derivado |
| D3 | Card number | **a** — usar `profile.registrationNumber` |
| D4 | Typar eventos | **a** — criar model `UpcomingEvent` freezed |
| D5 | HomeCubit silent failure | **a** — manter fallback + adicionar `debugPrint` |
| D6 | Accessibility | **a** — adicionar `Semantics` nos principais |
| D7 | findBirthdays perf | **a** — deixar para TCK futuro (documentado abaixo) |
| D8 | Fallback HomePage | **a** — placeholder visual `—` em vez de `"Membro"` |

### Execução por fase

#### Phase B — Tipagem do HomeState

**Novo**: `lib/features/home/domain/models/upcoming_event.dart`
- `@freezed abstract class UpcomingEvent` com `id`, `title`, `startsAt: DateTime`, `branchName: String?`, `type: String?`
- `factory UpcomingEvent.fromJson` **manual** (não usa `json_serializable`) porque precisa achatar `branch.name` aninhado e parsear ISO string → `DateTime`. Sem `part 'upcoming_event.g.dart'`.

**Alterações em cascata:**
- `home_state.dart`: `List<dynamic>` → `List<UpcomingEvent>` no factory `loaded`
- `home_repository.dart`: `getUpcomingEvents()` passa a retornar `Future<List<UpcomingEvent>>`, com `.map(UpcomingEvent.fromJson).toList()` dentro
- `home_cubit.dart`: o wrapper try/catch do `getUpcomingEvents` agora volta `const <UpcomingEvent>[]` em vez de um Map com `{data: []}`; emite a lista diretamente no `HomeState.loaded`
- `home_cubit_test.dart`: reescrito com testes nomeados behavioral, cobre as 5 combinações de falha parcial (happy path, church falha, birthdays falha, events falha, ambos auxiliares falham)

Build runner regenerou `upcoming_event.freezed.dart` e `home_state.freezed.dart`.

#### Phase C — Dashboard rewrite (TDD)

**Testes primeiro (RED)**: `test/features/home/pages/dashboard_page_test.dart` reescrito com 34 testes em 7 groups:
- Greeting (acentos)
- Member card front (registrationNumber real, placeholder fallback)
- Member card back (baptismDate real, accent headers, placeholder fallback) — usam um helper `flipToCardBack(tester)` que tapa o flip card e `pumpAndSettle` pra trazer a face do verso ao widget tree (antes o back só existia após a animação)
- Birthdays (empty state omite a seção inteira)
- Upcoming events (header, título, `branch.name` como location, empty card)
- Accessibility (Semantics label no flip card)
- Loading / Error / Initial states

**Dashboard rewrite**: `dashboard_page.dart` de ~840 linhas para ~680 linhas, organizado em sub-widgets privados:
- `_ErrorRetry` / `_LoadedBody` / `_SectionHeader` / `_MemberCardFront` / `_MemberCardBack` / `_BackField` / `_BirthdayAvatar` / `_EventCard` / `_EmptyEventsCard`
- Helper de formatação `_formatDate(isoDate)` → `"dd/MM/yyyy"` com fallback `"—"` pra null/malformed
- Todas as cores via `AppTheme`. Exceções locais documentadas:
  - Gradient roxo/dark do back do card (fora da paleta brand)
  - Cores do badge "Evento" (`_kEventBadgeBackground`/`_kEventBadgeForeground`) — taxonomia de tipo de evento, não token de marca. Comentário indica que vão pra theme extension quando a taxonomia crescer.
- Weekday abbreviations (`SEG`, `TER`, ..., `DOM`) extraídas para constante `_kWeekdayAbbrPtBR` com comentário explicando o índice.
- `FlipCard` envelopado em `Semantics(label: 'Carteira digital do membro — toque para girar', button: true, container: true)`.

#### Phase D — HomePage + shared widgets

**home_page.dart**:
- `_showProfileSheet` troca `'Membro'`/`'MEMBER'` por `'—'` como fallback
- `userInitial` ganha `'?'` visual (era `null` que fazia o avatar ficar vazio)

**app_bar_widget.dart**, **app_drawer.dart**, **custom_bottom_nav.dart**, **profile_bottom_sheet.dart**: reescritos pra usar `AppTheme.primary`, `AppTheme.surface`, `AppTheme.surfaceContainerHigh/Low/Lowest`, `AppTheme.secondaryContainer`, `AppTheme.primaryContainer`, `AppTheme.onPrimaryContainer`, `AppTheme.onSurface`, `AppTheme.onSurfaceVariant`, `AppTheme.outline`, `AppTheme.outlineVariant`, `AppTheme.error`, `AppTheme.radiusMd/Lg/Xl` em vez das literais hex.

**Semantics adicionadas:**
- `AtosAppBar`: `Semantics(label: 'Abrir menu', button: true)` no hambúrguer e `'Abrir menu de perfil'` no avatar
- `CustomBottomNav`: cada `_NavItemWidget` ganha `Semantics(label: item.label, button: true, selected: isActive)`

**profile_bottom_sheet.dart**:
- Role mapping agora tem branch explícito pra `MEMBER` (retorna `'Membro'`), mantém fallback default
- Versão `'2.4.0'` isolada em constante `_kAppVersionDisplay` com comentário `// TODO(build-info): read from package_info_plus`
- Conteúdo envolto em `SingleChildScrollView` (antes `Padding + Column`) pra sobreviver a viewports pequenos — o teste `HomePage - Profile bottom sheet` pegou um overflow real de 97px no viewport padrão 800x600

**app_drawer.dart**:
- Status verde extraído pra `_kStatusHealthyGreen` (constante local) com `// TODO(backend): replace the always-green dot with a real healthcheck`
- Subtitle `'Gestão Eclesiástica'` e todos os items usando theme tokens

**coming_soon_page.dart**: já usava `Theme.of(context)`, zero alteração necessária.

#### Phase E — Coverage

**Novo**: `tool/coverage_home.js` seguindo o padrão dos outros coverage tools.

**Gaps encontrados no primeiro run (87.7%):**
- `home_repository.dart` — 0/25 linhas (nunca testado)
- `church.dart`, `birthday_member.dart`, `upcoming_event.dart` — fromJson nunca chamadas
- `home_page.dart` — 46.4% (falta drawer, profile sheet, logout)
- `app_drawer.dart` — 90.4% (falta tapar 6 items do drawer)
- `profile_bottom_sheet.dart` — 97.8% (falta empty-name fallback)

**Novos arquivos de teste** pra fechar os gaps:
- `test/features/home/data/home_repository_test.dart` — 12 testes: happy path pra cada método, error path com NetworkException, forwarding dos query params, parse do nested `branch.name`, empty list, fallback PT-BR na msg genérica
- `test/features/home/domain/models/home_models_test.dart` — 10 testes pros fromJson de `Church`, `BirthdayMember`, `BirthdaysResponse`, `UpcomingEvent` (incluindo caminhos de branch ausente/malformado)

**Testes existentes expandidos:**
- `test/features/home/pages/home_page_test.dart` ganhou 13 testes novos em 4 groups: AppBar (initial fallback, profile-less fallback), Drawer interactions (open, navigate secretaria/branches/coming-soon), Profile bottom sheet (open, edit-profile, coming-soon, logout com `ensureVisible` porque o sheet é scrollável), Church name in drawer (loaded + initial fallback)
- `test/shared/widgets/app_drawer_test.dart` ganhou 7 testes — um pra cada item do drawer que não era testado (Secretaria, Finanças, Patrimônio, Relatórios, Certificados, Contribuições, Célula) com scroll + ensureVisible pros que ficam abaixo da fold
- `test/shared/widgets/profile_bottom_sheet_test.dart` ganhou 3 testes: MEMBER role explícito, role desconhecido (fallback), avatar placeholder `?` com nome vazio

#### Phase extra — Backend

Durante a Phase C, descobri que `UserProfileDetail` não tinha `baptismDate` **porque o backend não selecionava o campo**. O chain de fixes:

1. `src/modules/auth/auth.service.ts` — `getProfile()` query adicionou `baptismDate: true` ao `select` dos `memberProfiles` nested
2. `src/modules/auth/auth.service.spec.ts` — teste do `getProfile` ganhou `baptismDate: new Date('2018-06-10')` no mock da resposta e na expectation
3. `lib/features/auth/domain/models/user_profile.dart` — `UserProfileDetail` ganhou campo `String? baptismDate`
4. Build runner regenerou `user_profile.freezed.dart` + `user_profile.g.dart`
5. Dashboard lê `profile?.profile?.baptismDate` com fallback `"—"` via `_formatDate`

## Decisões Técnicas

### Por que `UpcomingEvent.fromJson` é manual

O backend retorna `{id, title, startsAt, branch: {id, name}}`. O mobile precisa de `{id, title, startsAt: DateTime, branchName: String?}`. O `json_serializable` gerado não consegue:
- Achatar `branch.name` → `branchName`
- Parsear `startsAt` ISO → `DateTime`

Tentativas com `@JsonKey(fromJson:)` ficaram frágeis (converters globais têm que lidar com vários tipos). A factory manual é 10 linhas, cobre o contrato exato da API e não precisa de json_serializable.

### Por que o home_cubit mantém fallback silencioso em vez de partial-load state

UX > completude. Um usuário que abre o app e vê o card da carteirinha e a seção de aniversariantes mas não os eventos ainda tem valor, e o erro é geralmente transitório. Um estado de "partial load" exige modelagem estrutural no `HomeState` e renderização explícita de erros por seção — complexidade alta pra pouco retorno. O `debugPrint` no cubit garante que quem está debugando vê a causa raiz; em produção o usuário vê o resto da tela.

### Por que `findBirthdays` performance fica pra outro ticket

O endpoint hoje roda `prisma.memberProfile.findMany({ where: { churchId }})` e filtra por mês em JS. Pra igrejas com 2000+ membros vira gargalo. O fix é trocar por `prisma.$queryRaw` com `EXTRACT(MONTH FROM "birthDate") = $1`. **Escopo é revisão do home mobile — performance de query backend é outro trabalho**. Flagado aqui como known issue.

### Por que o `ProfileBottomSheet` precisou de `SingleChildScrollView`

O teste `HomePage - Profile bottom sheet` pegou um overflow real de 97px no viewport 800x600. O modal bottom sheet tem altura máxima de ~50% da tela, e o conteúdo (header + avatar + nome + role + 3 items + versão) passa disso em telas pequenas. Em produção isso causaria um listrado amarelo/preto de debug e cortaria a versão. Solução: wrap em `SingleChildScrollView`. Pequeno, 1 linha, resolve o caso.

### Por que usamos `Semantics` só nos itens principais (não em toda a árvore)

Escolha de custo/benefício. Adicionei labels nos elementos que um screen reader precisaria narrar:
- Hambúrguer → "Abrir menu"
- Avatar → "Abrir menu de perfil"
- Flip card → "Carteira digital do membro — toque para girar"
- Bottom nav tabs → label + `selected: isActive`

A11y completa (keyboard navigation, focus management, live regions) é um épico separado e será tratado quando o app for disponibilizado em contextos que exijam compliance WCAG.

### Known issue — documentado

**`findBirthdays` backend performance**: a query atual carrega todos os `MemberProfile` da igreja e filtra em memória. OK pra MVPs mas escala mal. Próximo ticket sugerido: `TCK-XXX-optimize-birthdays-query` (trocar por `$queryRaw` com `EXTRACT(MONTH FROM ...)`). Nenhum impacto no TCK-007.

## Arquivos criados / modificados

### Backend

| Ação | Arquivo |
|---|---|
| Mod | `src/modules/auth/auth.service.ts` (`getProfile` seleciona `baptismDate`) |
| Mod | `src/modules/auth/auth.service.spec.ts` (mock + expectation com baptismDate) |

### Mobile

| Ação | Arquivo |
|---|---|
| Novo | `lib/features/home/domain/models/upcoming_event.dart` (+ `.freezed.dart` gerado) |
| Novo | `test/features/home/data/home_repository_test.dart` (12 testes) |
| Novo | `test/features/home/domain/models/home_models_test.dart` (10 testes) |
| Novo | `tool/coverage_home.js` |
| Novo | `.ai_docs/tickets/TCK-007-home-flow-review.md` (este arquivo) |
| Mod | `lib/features/auth/domain/models/user_profile.dart` (adicionou `baptismDate`) + freezed regen |
| Mod | `lib/features/home/presentation/cubit/home_state.dart` (`List<UpcomingEvent>`) + freezed regen |
| Mod | `lib/features/home/presentation/cubit/home_cubit.dart` (tipagem + docstring) |
| Mod | `lib/features/home/data/home_repository.dart` (`getUpcomingEvents` tipado) |
| Mod | `lib/features/home/presentation/pages/dashboard_page.dart` (rewrite completo) |
| Mod | `lib/features/home/presentation/pages/home_page.dart` (fallback `—`, doc) |
| Mod | `lib/shared/widgets/app_bar_widget.dart` (theme + Semantics) |
| Mod | `lib/shared/widgets/app_drawer.dart` (theme + healthcheck placeholder constant) |
| Mod | `lib/shared/widgets/custom_bottom_nav.dart` (theme + Semantics) |
| Mod | `lib/shared/widgets/profile_bottom_sheet.dart` (theme, role exhaustive, version constant, scroll) |
| Mod | `test/features/home/cubit/home_cubit_test.dart` (rewrite: 6 testes, todas as combinações) |
| Mod | `test/features/home/pages/dashboard_page_test.dart` (rewrite: 19 testes, 7 groups) |
| Mod | `test/features/home/pages/home_page_test.dart` (+13 testes: drawer, profile sheet, church fallback) |
| Mod | `test/shared/widgets/app_drawer_test.dart` (+7 testes — um por módulo) |
| Mod | `test/shared/widgets/profile_bottom_sheet_test.dart` (+3 testes — MEMBER, unknown, empty name) |

## Resultado dos Testes

### Mobile

```
$ flutter test
00:21 +329: All tests passed!
```

```
$ flutter test --coverage && node tool/coverage_home.js

Home Flow — Mobile Coverage Report
==========================================================================================================
File                                                                   Covered    Excluded         Status
----------------------------------------------------------------------------------------------------------
lib/features/home/data/home_repository.dart                     25/25 (100.0%)           -         ✓ 100%
lib/features/home/domain/models/birthday_member.dart              4/4 (100.0%)           -         ✓ 100%
lib/features/home/domain/models/church.dart                       2/2 (100.0%)           -         ✓ 100%
lib/features/home/domain/models/upcoming_event.dart               8/8 (100.0%)           -         ✓ 100%
lib/features/home/presentation/cubit/home_cubit.dart            23/23 (100.0%)           -         ✓ 100%
lib/features/home/presentation/pages/dashboard_page.dart      270/270 (100.0%)           -         ✓ 100%
lib/features/home/presentation/pages/home_page.dart             56/56 (100.0%)           -         ✓ 100%
lib/features/home/presentation/widgets/flip_card.dart           36/36 (100.0%)           -         ✓ 100%
lib/shared/widgets/app_bar_widget.dart                          30/30 (100.0%)           -         ✓ 100%
lib/shared/widgets/app_drawer.dart                              73/73 (100.0%)           -         ✓ 100%
lib/shared/widgets/coming_soon_page.dart                        16/16 (100.0%)           -         ✓ 100%
lib/shared/widgets/custom_bottom_nav.dart                       38/38 (100.0%)           -         ✓ 100%
lib/shared/widgets/profile_bottom_sheet.dart                    46/46 (100.0%)           -         ✓ 100%
----------------------------------------------------------------------------------------------------------
TOTAL (home flow, excl. documented skips)                     627/627 (100.0%)           0
```

```
$ flutter analyze lib/features/home lib/shared/widgets test/features/home test/shared/widgets
No issues found!
```

### Backend

```
$ npx jest
Test Suites: 11 passed, 11 total
Tests:       88 passed, 88 total
```

### Regressão dos fluxos anteriores

| Fluxo | Linhas cobertas | Status |
|---|---:|---|
| Login | 339/339 (100%) | inalterado (20 exclusões documentadas) |
| Register | 333/333 (100%) | inalterado (0 exclusões) |
| Select-Church | 232/232 (100%) | inalterado (0 exclusões) |
| **Home (novo)** | **627/627 (100%)** | **0 exclusões** |

### Total de testes

- **Mobile**: 272 → **329** (+57)
- **Backend**: 88 (inalterado + 1 teste do `getProfile` atualizado)

## Como verificar / testar

### Pré-requisito: usuário com MemberProfile + dados

Pra ver a tela home com todos os seus elementos populados, o user precisa ter:
- Uma `Church` ativa
- Uma `MemberProfile` row (com `birthDate`, `baptismDate`, `admissionDate`, `registrationNumber`)
- Pelo menos um `Event` na Church (com `branch` populado) pra aparecer em "Próximos Eventos"
- Pelo menos um `MemberProfile` com `birthDate` no mês atual pra aparecer em "Aniversariantes do Mês"

Fluxo de seed manual (Prisma Studio) caso precise:
1. User já existe (signup básico) → tem Church + Branch + Membership
2. Criar `MemberProfile` linkando user ao church, preencher datas
3. Criar `Event` linkado ao church + branch, com `startsAt` futuro

### Comandos de verificação

```bash
cd atos_logos_mobile
flutter test                              # 329/329
flutter test --coverage                   # gera lcov
node tool/coverage_home.js                # 627/627 (100%)
flutter analyze                           # clean
```

```bash
cd atos-logos-backend
npx jest                                  # 88/88
npx nest build                            # clean
```

### Checklist de teste manual

**Dashboard renderizado:**
- [ ] Saudação "Olá, [nome]" com acento correto
- [ ] Subtítulo "Que bom ter você aqui hoje."
- [ ] Flip card mostra nome, cargo, número real de matrícula (ex: `2020-ABCD-001`)
- [ ] Tap no card gira — back mostra datas formatadas `dd/MM/yyyy`
- [ ] Seção "Aniversariantes do Mês" só aparece se houver dados
- [ ] Seção "Próximos Eventos" mostra card por evento, com data/hora e nome da branch como local
- [ ] Empty card "Nenhum evento cadastrado" quando não há eventos
- [ ] Loading state: spinner azul enquanto carrega
- [ ] Error state: mensagem + botão "Tentar novamente" funcionando

**Home shell:**
- [ ] AppBar mostra hamburger, "Atos Logos", avatar com inicial do user
- [ ] Tap no hamburger abre o drawer
- [ ] Drawer mostra nome da igreja no header
- [ ] Tap em "Secretaria" → /secretaria
- [ ] Tap em "Congregações" → /branches
- [ ] Outros items (Finanças, Patrimônio, Relatórios, etc.) → /coming-soon
- [ ] Tap no avatar abre o profile bottom sheet
- [ ] Sheet mostra nome, role localizado, "Meu Perfil", "Configurações", "Sair" e versão
- [ ] Tap em "Meu Perfil" → /edit-profile
- [ ] Tap em "Sair" → chama logout + /login
- [ ] Bottom nav tem 3 tabs (Início, Agenda, Notificações)
- [ ] Tap em Agenda/Notificações → ComingSoonPage

**Screen reader / a11y mínimo:**
- [ ] Hambúrguer anunciado como "Abrir menu"
- [ ] Avatar anunciado como "Abrir menu de perfil"
- [ ] Flip card anunciado como "Carteira digital do membro — toque para girar"
- [ ] Cada tab do bottom nav anuncia o label e se está selecionado

## Próximos passos

1. **Épico de performance do backend** — `TCK-XXX-optimize-birthdays-query`: trocar a query em memória por `$queryRaw` com `EXTRACT(MONTH FROM "birthDate")`. Prioridade: baixa até ter igrejas com > 500 membros ativos.
2. **Feature real do Agenda** (Bottom nav tab 2): tela real com calendário + eventos + agendamento próprio. Scope grande.
3. **Feature real do Notificações** (Bottom nav tab 3): provavelmente via `notifications` endpoint + sistema de push.
4. **Épico de a11y** (keyboard navigation, focus management, live regions, labels em todos os ListTile do drawer).
5. **Épico de i18n** (`intl`/`l10n`) unificando todas as strings PT-BR em arquivos de tradução.
6. **Backend `package_info_plus`** no mobile + integração com `_kAppVersionDisplay` pra versão real vir do pubspec.
7. **`/healthz` endpoint** no backend + consumir no status do drawer (hoje sempre verde).
