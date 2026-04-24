# member-edit-data-loading Bugfix Design

## Overview

A tela `EditMemberPage` não pré-preenche os campos do formulário com os dados existentes do membro ao ser aberta. O bug afeta todos os 18 controllers de texto e os 2 campos de estado (dropdowns de sexo e estado civil), totalizando 20 campos afetados.

A causa raiz é uma combinação de dois problemas relacionados ao ciclo de vida do Flutter:

1. **Flag prematura**: `_populateControllersOnce` é chamado dentro do `BlocBuilder.builder`. Na primeira chamada (estado `loading`), `whenOrNull(loaded: ...)` não executa — mas a flag `_controllersPopulated` **não** é setada como `true` nesse momento. Portanto, quando o estado transita para `loaded`, a flag ainda é `false` e o bloco `loaded` executa corretamente para os `TextEditingController`s.

2. **Dropdowns não refletem o valor**: `_selectedSex` e `_selectedCivilStatus` são setados dentro do `builder` do `BlocBuilder` (durante o ciclo de build). Os `DropdownButtonFormField` usam `initialValue`, que é lido apenas na criação do widget. Quando `_populateControllersOnce` seta `_selectedSex` e `_selectedCivilStatus` durante um rebuild, **não há `setState`** sendo chamado — o que é correto, pois chamar `setState` dentro do `build` é proibido no Flutter. Resultado: os dropdowns permanecem sem valor selecionado mesmo após o estado `loaded` ser emitido.

A solução é migrar `_populateControllersOnce` para um `BlocListener` (via `BlocConsumer`), que é chamado **fora** do ciclo de build, permitindo `setState` seguro para atualizar `_selectedSex`, `_selectedCivilStatus` e a flag `_controllersPopulated`.

## Glossary

- **Bug_Condition (C)**: A condição que dispara o bug — `_populateControllersOnce` é chamado dentro do `builder` do `BlocBuilder`, impedindo `setState` seguro para os dropdowns
- **Property (P)**: O comportamento desejado — todos os 20 campos do formulário devem refletir os dados do `MemberProfile` após o estado `loaded` ser emitido
- **Preservation**: O comportamento existente que não deve ser alterado pela correção — edições manuais da secretaria, navegação, salvamento, tratamento de erros
- **`_populateControllersOnce`**: Método em `EditMemberPage` (`edit_member_page.dart`) responsável por preencher os controllers uma única vez quando o estado `loaded` é recebido
- **`_controllersPopulated`**: Flag booleana que garante preenchimento único, evitando sobrescrever edições manuais da secretaria em rebuilds subsequentes
- **`BlocBuilder`**: Widget do `flutter_bloc` cujo `builder` é chamado durante o ciclo de build — **não permite `setState`**
- **`BlocConsumer`**: Widget do `flutter_bloc` que combina `BlocBuilder` (para UI) e `BlocListener` (para efeitos colaterais fora do build) — **o `listener` permite `setState`**
- **`BlocListener`**: Callback do `BlocConsumer` chamado fora do ciclo de build, seguro para `setState` e outras operações com efeitos colaterais
- **`initialValue`**: Parâmetro do `DropdownButtonFormField` lido apenas na criação do widget — não reflete mudanças posteriores sem `setState`
- **`ProfileCubit`**: Cubit responsável por carregar o `MemberProfile` via `loadMemberProfileByUserId`
- **`ProfileState`**: Estados possíveis: `initial`, `loading`, `loaded`, `saving`, `saved`, `error`

## Bug Details

### Bug Condition

O bug manifesta-se quando `_populateControllersOnce` é chamado dentro do `BlocBuilder.builder` e o estado transita de `loading` para `loaded`. Os `TextEditingController`s são preenchidos corretamente (pois notificam listeners diretamente), mas `_selectedSex` e `_selectedCivilStatus` não são atualizados na UI porque não há `setState` — e chamar `setState` dentro do `build` é proibido.

**Formal Specification:**
```
FUNCTION isBugCondition(state, context)
  INPUT: state of type ProfileState, context of type BuildContext
  OUTPUT: boolean

  // O bug ocorre quando _populateControllersOnce é chamado dentro do
  // BlocBuilder.builder com estado loaded, pois:
  // - TextEditingControllers são preenchidos (notificam listeners diretamente)
  // - _selectedSex e _selectedCivilStatus são setados mas sem setState
  // - DropdownButtonFormField usa initialValue (lido apenas na criação)
  // - Resultado: dropdowns permanecem sem valor selecionado na UI

  RETURN state IS ProfileState.loaded
         AND _populateControllersOnce IS CALLED INSIDE BlocBuilder.builder
         AND (profile.user?.sex IS NOT NULL OR profile.user?.civilStatus IS NOT NULL)
         AND setState IS NOT CALLED after setting _selectedSex/_selectedCivilStatus
END FUNCTION
```

### Campos Afetados

**Controllers de texto (18 campos)** — preenchidos via `TextEditingController.text =`:
| Controller | Fonte |
|---|---|
| `_nameController` | `profile.user?.name` |
| `_emailController` | `profile.user?.email` |
| `_cpfController` | `profile.user?.cpf` |
| `_phoneController` | `profile.user?.phone` |
| `_birthDateController` | `profile.birthDate` via `_isoToDisplay` |
| `_baptismDateController` | `profile.baptismDate` via `_isoToDisplay` |
| `_admissionDateController` | `profile.admissionDate` via `_isoToDisplay` |
| `_consecrationDateController` | `profile.consecrationDate` via `_isoToDisplay` |
| `_rgController` | `profile.user?.rg` |
| `_fatherNameController` | `profile.user?.fatherName` |
| `_motherNameController` | `profile.user?.motherName` |
| `_countryController` | `profile.user?.country` |
| `_stateController` | `profile.user?.state` |
| `_cityController` | `profile.user?.city` |
| `_neighborhoodController` | `profile.user?.neighborhood` |
| `_streetController` | `profile.user?.street` |
| `_numberController` | `profile.user?.number` |
| `_complementController` | `profile.user?.complement` |

**Campos de estado (2 campos)** — afetados pelo bug de `setState` ausente:
| Campo | Fonte |
|---|---|
| `_selectedSex` | `_sexFromWire(profile.user?.sex)` |
| `_selectedCivilStatus` | `_civilStatusFromWire(profile.user?.civilStatus)` |

**Campos NÃO afetados** (carregados via `_loadDropdownData`, repositório separado):
- `_selectedPosition` — carregado via `PositionsRepository`
- `_selectedBranch` — carregado via `BranchesRepository`

### Examples

- **Exemplo 1 (dropdown)**: Membro com `sex: 'FEMALE'` — ao abrir a tela, o campo "SEXO" aparece vazio (sem seleção) em vez de mostrar "Feminino"
- **Exemplo 2 (dropdown)**: Membro com `civilStatus: 'MARRIED'` — ao abrir a tela, o campo "ESTADO CIVIL" aparece vazio em vez de mostrar "Casado(a)"
- **Exemplo 3 (texto — comportamento atual)**: Membro com `name: 'Ana Silva'` — o campo "NOME COMPLETO" é preenchido corretamente porque `TextEditingController` notifica listeners diretamente, sem precisar de `setState`
- **Exemplo 4 (edge case)**: Membro sem `sex` e sem `civilStatus` — os dropdowns devem permanecer sem seleção (comportamento correto, não é bug)

## Expected Behavior

### Preservation Requirements

**Unchanged Behaviors:**
- Edições manuais da secretaria em qualquer campo não devem ser sobrescritas por rebuilds do `BlocBuilder` (preenchimento único via `_controllersPopulated`)
- Cliques no botão "Salvar Registro" devem continuar chamando `MembersCubit.updateMemberUserData` e `MembersCubit.updateMemberProfile` com os valores corretos
- Navegação de volta ao salvar com sucesso deve continuar funcionando
- Exibição de snackbar de erro ao falhar o salvamento deve continuar funcionando
- Exibição de `CircularProgressIndicator` durante o estado `loading` deve continuar funcionando
- Exibição de mensagem de erro durante o estado `error` deve continuar funcionando
- O botão "Inativar Membro" e o diálogo de confirmação devem continuar funcionando
- Carregamento dos dropdowns de cargo e congregação via `_loadDropdownData` deve continuar funcionando
- Conversão de datas ISO → display (`_isoToDisplay`) e display → ISO (`_toIsoDate`) deve continuar funcionando

**Scope:**
Todos os inputs que NÃO envolvem o preenchimento inicial dos dropdowns de sexo e estado civil devem ser completamente não afetados por esta correção. Isso inclui:
- Interações de toque/clique nos campos do formulário
- Digitação em campos de texto
- Seleção de datas via `showDatePicker`
- Salvamento e inativação do membro

**Nota:** O comportamento correto esperado está definido nas Correctness Properties (Property 1). Esta seção foca no que NÃO deve mudar.

## Hypothesized Root Cause

Com base na análise do código, as causas são:

1. **`setState` proibido dentro do `build`**: `_populateControllersOnce` é chamado dentro do `BlocBuilder.builder`. Quando o estado `loaded` é recebido, o método seta `_selectedSex` e `_selectedCivilStatus` diretamente nas variáveis de instância, mas **não chama `setState`** — o que seria correto fazer dentro do `build`, pois causaria um erro de "setState called during build". Resultado: os dropdowns não são notificados da mudança.

2. **`DropdownButtonFormField` usa `initialValue`**: O parâmetro `initialValue` é lido apenas uma vez, na criação do widget. Quando `_selectedSex` é atualizado sem `setState`, o dropdown não reconstrói e permanece sem seleção.

3. **`TextEditingController` não tem o mesmo problema**: Ao contrário dos dropdowns, `TextEditingController.text = value` notifica seus listeners diretamente (via `ChangeNotifier`), fazendo o `TextFormField` reconstruir automaticamente sem precisar de `setState`. Por isso os campos de texto funcionam e os dropdowns não.

4. **Solução**: Mover `_populateControllersOnce` para o `listener` de um `BlocConsumer`. O `listener` é chamado fora do ciclo de build, tornando `setState` seguro. Isso garante que `_selectedSex`, `_selectedCivilStatus` e `_controllersPopulated` sejam atualizados com `setState` quando o estado `loaded` é emitido.

## Correctness Properties

Property 1: Bug Condition — Dropdowns pré-preenchidos com dados do membro

_For any_ `MemberProfile` carregado onde `profile.user?.sex` ou `profile.user?.civilStatus` é não-nulo, após o `ProfileCubit` emitir `ProfileState.loaded`, a `EditMemberPage` corrigida SHALL exibir o valor correspondente selecionado nos `DropdownButtonFormField` de sexo e estado civil, refletindo os dados do membro sem interação manual da secretaria.

**Validates: Requirements 2.1, 2.2, 2.3**

Property 2: Preservation — Edições manuais não sobrescritas por rebuilds

_For any_ texto digitado pela secretaria em qualquer campo do formulário após o preenchimento inicial, quando o `BlocBuilder` reconstrói o widget por qualquer motivo (ex: mudança de estado do `MembersCubit`), a `EditMemberPage` corrigida SHALL preservar o texto digitado, não revertendo para o valor original do `MemberProfile`.

**Validates: Requirements 3.1, 3.3**

## Fix Implementation

### Changes Required

Assumindo que a análise de causa raiz está correta:

**File**: `atos_logos_mobile/lib/features/members/presentation/pages/edit_member_page.dart`

**Approach**: Substituir `BlocBuilder<ProfileCubit, ProfileState>` por `BlocConsumer<ProfileCubit, ProfileState>`

**Specific Changes**:

1. **Substituir `BlocBuilder` por `BlocConsumer`**: Adicionar um `listener` que chama `_populateControllersOnce` com `setState` quando o estado é `loaded`

2. **Mover lógica de preenchimento para o `listener`**: O `listener` é chamado fora do ciclo de build, tornando `setState` seguro

3. **Adicionar `setState` em `_populateControllersOnce`**: Envolver a atualização de `_selectedSex`, `_selectedCivilStatus` e `_controllersPopulated` em `setState`

4. **Remover chamada do `builder`**: Remover `_populateControllersOnce(state)` do `builder` do `BlocConsumer`

5. **Adicionar `listenWhen`**: Filtrar o listener para disparar apenas quando o estado transita para `loaded`, evitando chamadas desnecessárias

**Pseudocode da solução:**
```
// ANTES (bugado):
BlocBuilder<ProfileCubit, ProfileState>(
  builder: (context, state) {
    _populateControllersOnce(state);  // ← dentro do build, setState proibido
    return state.maybeWhen(...);
  },
)

// DEPOIS (corrigido):
BlocConsumer<ProfileCubit, ProfileState>(
  listenWhen: (previous, current) => current is _Loaded,
  listener: (context, state) {
    // Fora do build — setState é seguro aqui
    _populateControllersOnce(state);
  },
  builder: (context, state) {
    // Sem chamada a _populateControllersOnce aqui
    return state.maybeWhen(...);
  },
)

// _populateControllersOnce atualizado:
void _populateControllersOnce(ProfileState state) {
  if (_controllersPopulated) return;
  state.whenOrNull(
    loaded: (profile) {
      setState(() {  // ← seguro porque chamado do listener
        _profileId = profile.id;
        _nameController.text = profile.user?.name ?? '';
        // ... todos os outros controllers ...
        _selectedSex = _sexFromWire(profile.user?.sex);
        _selectedCivilStatus = _civilStatusFromWire(profile.user?.civilStatus);
        _controllersPopulated = true;
      });
    },
  );
}
```

**Nota sobre compatibilidade com testes existentes**: O comentário atual no código menciona que o `BlocBuilder` foi escolhido em vez de `BlocListener` porque "a listener only fires on state TRANSITIONS, so a test that seeds the cubit with `loaded` up-front would never run it." Com `BlocConsumer`, o `listener` também só dispara em transições. Para garantir que testes que iniciam com estado `loaded` funcionem, o `listenWhen` deve ser configurado para também disparar quando o estado inicial já é `loaded` — ou os testes devem emitir uma transição explícita. Avaliar durante a implementação.

## Testing Strategy

### Validation Approach

A estratégia de testes segue duas fases: primeiro, demonstrar o bug no código não corrigido (exploratory); depois, verificar que a correção funciona e não introduz regressões (fix checking + preservation checking).

### Exploratory Bug Condition Checking

**Goal**: Demonstrar o bug ANTES de implementar a correção. Confirmar ou refutar a análise de causa raiz. Se refutarmos, precisamos re-hipotetizar.

**Test Plan**: Montar `EditMemberPage` com `ProfileCubit` que emite `[loading → loaded]` com um `MemberProfile` contendo `sex: 'FEMALE'` e `civilStatus: 'MARRIED'`. Verificar que os dropdowns permanecem sem seleção após o estado `loaded` ser emitido. Executar no código NÃO corrigido para observar a falha.

**Test Cases**:
1. **Dropdown Sexo vazio**: Montar com `sex: 'FEMALE'`, verificar que `find.text('Feminino')` não encontra o valor selecionado no dropdown (falhará no código não corrigido)
2. **Dropdown Estado Civil vazio**: Montar com `civilStatus: 'MARRIED'`, verificar que `find.text('Casado(a)')` não encontra o valor selecionado (falhará no código não corrigido)
3. **Transição loading → loaded**: Emitir `loading` primeiro, depois `loaded`, verificar que os dropdowns ainda estão vazios (demonstra o bug de `setState` ausente)
4. **Campos de texto funcionam**: Verificar que `_nameController` e outros `TextFormField`s são preenchidos corretamente mesmo no código não corrigido (confirma que o bug é específico aos dropdowns)

**Expected Counterexamples**:
- Dropdowns de sexo e estado civil não refletem os valores do `MemberProfile` após `loaded`
- Possíveis causas: `setState` não chamado dentro do `build`, `initialValue` do dropdown lido apenas na criação

### Fix Checking

**Goal**: Verificar que para todos os inputs onde a condição de bug se aplica, a função corrigida produz o comportamento esperado.

**Pseudocode:**
```
FOR ALL profile WHERE profile.user?.sex IS NOT NULL
                   OR profile.user?.civilStatus IS NOT NULL DO
  // Montar EditMemberPage com ProfileState.loaded(profile)
  result ← buildWidget(EditMemberPage, ProfileState.loaded(profile))
  ASSERT dropdownSex.selectedValue = _sexFromWire(profile.user?.sex)
  ASSERT dropdownCivilStatus.selectedValue = _civilStatusFromWire(profile.user?.civilStatus)
  ASSERT allTextControllers.text = correspondingProfileField
END FOR
```

### Preservation Checking

**Goal**: Verificar que para todos os inputs onde a condição de bug NÃO se aplica, a função corrigida produz o mesmo resultado que a função original.

**Pseudocode:**
```
FOR ALL (field, newValue) WHERE field IS ANY form field
                              AND newValue IS typed by secretary DO
  // Após preenchimento inicial, digitar novo valor
  typeInField(field, newValue)
  // Forçar rebuild do BlocConsumer
  triggerRebuild()
  ASSERT field.currentValue = newValue  // não reverteu para valor original
END FOR
```

**Testing Approach**: Testes de widget são recomendados para preservation checking porque:
- Simulam o ciclo de vida real do Flutter (build → rebuild)
- Verificam que `setState` não sobrescreve edições manuais
- Cobrem edge cases de campos nulos vs. não-nulos

**Test Plan**: Observar comportamento no código NÃO corrigido primeiro para interações de toque e digitação, depois escrever testes de widget capturando esse comportamento.

**Test Cases**:
1. **Preservação de texto editado**: Digitar em `_nameController` após preenchimento, forçar rebuild, verificar que o texto editado persiste
2. **Preservação de dropdown editado**: Selecionar um valor diferente no dropdown de sexo após preenchimento, forçar rebuild, verificar que a seleção persiste
3. **Preservação de estado de loading**: Verificar que `CircularProgressIndicator` ainda aparece durante `loading`
4. **Preservação de estado de erro**: Verificar que mensagem de erro ainda aparece durante `error`

### Unit Tests

- Testar `_isoToDisplay` com datas válidas, nulas e malformadas
- Testar `_toIsoDate` com datas válidas, nulas e malformadas (round-trip)
- Testar `_sexFromWire` e `_civilStatusFromWire` com todos os valores wire e valores inválidos
- Testar `_populateControllersOnce` com estado `loaded` (deve preencher todos os 20 campos)
- Testar `_populateControllersOnce` com estado `loading` (não deve preencher nada)
- Testar `_populateControllersOnce` chamado duas vezes com `loaded` (segunda chamada deve ser no-op)

### Property-Based Tests

- Gerar `MemberProfile`s aleatórios com campos opcionais nulos/não-nulos e verificar que todos os 20 campos do formulário refletem os valores corretos após `loaded`
- Gerar strings aleatórias de datas ISO e verificar que `_isoToDisplay` → `_toIsoDate` é um round-trip lossless para datas válidas
- Gerar sequências aleatórias de estados do `ProfileCubit` e verificar que `_controllersPopulated` só é setado como `true` após o primeiro `loaded`

### Integration Tests (Widget Tests)

- Testar fluxo completo: montar `EditMemberPage` → emitir `loading` → emitir `loaded` → verificar todos os 20 campos preenchidos
- Testar que dropdowns de sexo e estado civil exibem o valor correto após `loaded` (regressão principal)
- Testar que editar um campo e salvar chama `MembersCubit` com o valor editado (não o original)
- Testar que campos nulos no `MemberProfile` resultam em campos vazios no formulário (não crash)
- Testar que o formulário funciona corretamente quando `MemberProfile` não tem `user` (edge case)
