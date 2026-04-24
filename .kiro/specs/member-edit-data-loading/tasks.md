# Implementation Plan

- [ ] 1. Escrever teste de exploração da condição de bug (ANTES de implementar a correção)
  - **Property 1: Bug Condition** - Dropdowns de Sexo e Estado Civil não pré-preenchidos
  - **CRITICAL**: Este teste DEVE FALHAR no código não corrigido — a falha confirma que o bug existe
  - **DO NOT attempt to fix the test or the code when it fails**
  - **NOTE**: Este teste codifica o comportamento esperado — ele validará a correção quando passar após a implementação
  - **GOAL**: Demonstrar que `_selectedSex` e `_selectedCivilStatus` não são refletidos nos dropdowns quando `_populateControllersOnce` é chamado dentro do `BlocBuilder.builder`
  - **Scoped PBT Approach**: Escopo determinístico — usar `MemberProfile` concreto com `sex: 'FEMALE'` e `civilStatus: 'MARRIED'`, emitir transição `loading → loaded`
  - No arquivo `atos_logos_mobile/test/features/members/pages/edit_member_page_test.dart`, adicionar grupo `EditMemberPage - Bug Condition (dropdowns não pré-preenchidos)`
  - Montar `EditMemberPage` com `ProfileCubit` que emite `[loading → loaded]` com `MemberProfile` contendo `sex: 'FEMALE'` e `civilStatus: 'MARRIED'`
  - Usar `whenListen` do `bloc_test` para simular a transição de estados: `initialState: ProfileState.loading()`, `stream: Stream.fromIterable([ProfileState.loaded(profile: richProfile)])`
  - Verificar que `find.text('Feminino')` encontra o valor selecionado no dropdown de Sexo após `pumpAndSettle`
  - Verificar que `find.text('Casado(a)')` encontra o valor selecionado no dropdown de Estado Civil após `pumpAndSettle`
  - Executar no código NÃO corrigido: `flutter test atos_logos_mobile/test/features/members/pages/edit_member_page_test.dart --run`
  - **EXPECTED OUTCOME**: Teste FALHA (isso é correto — prova que o bug existe)
  - Documentar os counterexamples encontrados: ex. "Dropdown Sexo permanece vazio após transição loading→loaded com sex='FEMALE'"
  - Marcar tarefa como completa quando o teste estiver escrito, executado e a falha documentada
  - _Requirements: 1.1, 1.2, 2.1, 2.2_

- [ ] 2. Escrever testes de preservação (ANTES de implementar a correção)
  - **Property 2: Preservation** - Comportamento existente não afetado pela correção
  - **IMPORTANT**: Seguir metodologia observation-first
  - Observar comportamento no código NÃO corrigido para inputs que NÃO envolvem a condição de bug (isBugCondition = false)
  - No arquivo `atos_logos_mobile/test/features/members/pages/edit_member_page_test.dart`, adicionar grupo `EditMemberPage - Preservation`
  - **Caso 1 — Preenchimento único (não sobrescreve edições manuais)**: Montar com estado `loaded` inicial, verificar que `_nameController` está preenchido com 'Ana Silva', digitar 'Ana Costa' no campo, forçar rebuild emitindo novo estado via `mockProfile`, verificar que o campo ainda contém 'Ana Costa' (não reverteu para 'Ana Silva')
  - **Caso 2 — CircularProgressIndicator durante loading**: Montar com `ProfileState.loading()`, verificar que `find.byType(CircularProgressIndicator)` encontra o widget
  - **Caso 3 — Mensagem de erro durante estado error**: Montar com `ProfileState.error(message: 'Erro de rede')`, verificar que `find.text('Erro de rede')` encontra o widget
  - **Caso 4 — Salvamento chama MembersCubit com valores corretos**: Verificar que após preenchimento inicial e toque em 'Salvar Registro', `updateMemberUserData` é chamado com os valores do perfil (já coberto pelos testes existentes — confirmar que continuam passando)
  - Executar no código NÃO corrigido: `flutter test atos_logos_mobile/test/features/members/pages/edit_member_page_test.dart --run`
  - **EXPECTED OUTCOME**: Testes PASSAM (confirma o comportamento baseline a preservar)
  - Marcar tarefa como completa quando os testes estiverem escritos, executados e passando no código não corrigido
  - _Requirements: 3.1, 3.3, 3.4, 3.5_

- [ ] 3. Corrigir bug de pré-preenchimento dos dropdowns em EditMemberPage

  - [ ] 3.1 Substituir `BlocBuilder` por `BlocConsumer` e mover `_populateControllersOnce` para o listener
    - No arquivo `atos_logos_mobile/lib/features/members/presentation/pages/edit_member_page.dart`
    - Substituir `BlocBuilder<ProfileCubit, ProfileState>` por `BlocConsumer<ProfileCubit, ProfileState>`
    - Adicionar `listenWhen: (previous, current) => current is ProfileStateLoaded` para filtrar o listener apenas para o estado `loaded`
    - Adicionar `listener: (context, state) { _populateControllersOnce(state); }` — o listener é chamado fora do ciclo de build, tornando `setState` seguro
    - Remover a chamada `_populateControllersOnce(state)` do `builder` do `BlocConsumer`
    - Manter o `builder` inalterado (apenas remove a chamada ao método de preenchimento)
    - **Nota sobre testes com estado inicial `loaded`**: O `listener` do `BlocConsumer` só dispara em transições. Para testes que iniciam com `ProfileState.loaded` via `when(() => mockProfile.state).thenReturn(...)`, o `listener` não será chamado. Avaliar se os testes existentes precisam ser ajustados para usar `whenListen` com transição explícita, ou se o `listenWhen` deve incluir lógica para o estado inicial
    - _Bug_Condition: `_populateControllersOnce` chamado dentro do `BlocBuilder.builder` com estado `loaded`, sem `setState` para `_selectedSex`/`_selectedCivilStatus`_
    - _Expected_Behavior: após `ProfileState.loaded` ser emitido, todos os 20 campos do formulário refletem os dados do `MemberProfile`_
    - _Preservation: edições manuais da secretaria não são sobrescritas; `CircularProgressIndicator` durante `loading`; mensagem de erro durante `error`; salvamento e inativação continuam funcionando_
    - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.3_

  - [ ] 3.2 Adicionar `setState` dentro de `_populateControllersOnce`
    - Envolver toda a lógica do bloco `loaded:` em `setState(() { ... })` dentro de `_populateControllersOnce`
    - O `setState` deve incluir: `_profileId`, todos os 18 `TextEditingController`s, `_selectedSex`, `_selectedCivilStatus` e `_controllersPopulated = true`
    - Remover a atribuição direta de `_controllersPopulated = true` fora do `setState` (se existir)
    - Verificar que o guard `if (_controllersPopulated) return;` permanece no início do método (antes do `setState`) para garantir preenchimento único
    - _Bug_Condition: `_selectedSex` e `_selectedCivilStatus` setados sem `setState`, `DropdownButtonFormField` usa `initialValue` lido apenas na criação_
    - _Expected_Behavior: `setState` envolve todas as atualizações de estado, garantindo que os dropdowns reconstruam com os novos valores_
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 3.3 Ajustar testes existentes para compatibilidade com `BlocConsumer`
    - Os testes existentes usam `when(() => mockProfile.state).thenReturn(ProfileState.loaded(...))` — o `listener` do `BlocConsumer` não dispara para estado inicial (sem transição)
    - Avaliar cada grupo de testes existente e determinar se precisam de `whenListen` para simular a transição `loading → loaded`
    - Para testes que verificam preenchimento de campos (Layout, Identity fields, Date fields), migrar para `whenListen` com `initialState: ProfileState.loading()` e `stream: Stream.fromIterable([ProfileState.loaded(profile: ...)])`
    - Para testes que verificam comportamento de salvamento e inativação (Save, Inactivate), verificar se o preenchimento inicial ainda ocorre corretamente após a migração
    - Garantir que todos os testes existentes continuem passando após a migração
    - _Requirements: 2.2, 3.1, 3.3, 3.5_

  - [ ] 3.4 Verificar que o teste de exploração da condição de bug agora passa
    - **Property 1: Expected Behavior** - Dropdowns pré-preenchidos após `BlocConsumer` listener
    - **IMPORTANT**: Re-executar o MESMO teste da tarefa 1 — NÃO escrever um novo teste
    - O teste da tarefa 1 codifica o comportamento esperado
    - Quando este teste passar, confirma que o comportamento esperado está satisfeito
    - Executar: `flutter test atos_logos_mobile/test/features/members/pages/edit_member_page_test.dart --run`
    - **EXPECTED OUTCOME**: Teste PASSA (confirma que o bug foi corrigido)
    - _Requirements: 2.1, 2.2, 2.3_

  - [ ] 3.5 Verificar que os testes de preservação continuam passando
    - **Property 2: Preservation** - Comportamento existente preservado após a correção
    - **IMPORTANT**: Re-executar os MESMOS testes da tarefa 2 — NÃO escrever novos testes
    - Executar: `flutter test atos_logos_mobile/test/features/members/pages/edit_member_page_test.dart --run`
    - **EXPECTED OUTCOME**: Testes PASSAM (confirma que não há regressões)
    - Confirmar que todos os testes passam após a correção (sem regressões)

- [ ] 4. Checkpoint — Garantir que todos os testes passam
  - Executar a suite completa de testes do módulo members: `flutter test atos_logos_mobile/test/features/members/ --run`
  - Verificar que todos os testes passam, incluindo os novos (tarefas 1 e 2) e os existentes
  - Se algum teste falhar inesperadamente, investigar e corrigir antes de prosseguir
  - Perguntar ao usuário se houver dúvidas sobre o comportamento esperado
