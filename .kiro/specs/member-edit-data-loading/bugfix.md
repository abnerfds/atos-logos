# Bugfix Requirements Document

## Introduction

Ao abrir a tela de edição de um membro (`EditMemberPage`), os dados existentes do membro não são completamente pré-preenchidos nos campos do formulário. Campos como CPF, telefone, data de nascimento, RG, nome do pai/mãe, endereço e outros aparecem vazios, mesmo que essas informações existam no banco de dados. O bug afeta a experiência da secretaria, que precisa redigitar dados já cadastrados a cada edição.

A causa raiz está na forma como o `EditMemberPage` consome o estado do `ProfileCubit`: o método `_populateControllersOnce` é chamado dentro do `BlocBuilder.builder`, que é executado durante o ciclo de build do widget. Nesse momento, o `ProfileCubit` ainda está no estado `loading` (a requisição à API ainda não completou), então `state.whenOrNull(loaded: ...)` não executa o bloco de preenchimento. Quando o estado transita para `loaded`, o `BlocBuilder` reconstrói o widget e chama `_populateControllersOnce` novamente — mas a flag `_controllersPopulated` já foi setada como `true` na primeira chamada (mesmo sem ter preenchido nada), impedindo o preenchimento real.

## Bug Analysis

### Current Behavior (Defect)

1.1 WHEN a secretaria abre a tela de edição de um membro que possui CPF, telefone, data de nascimento, RG, nome do pai, nome da mãe, endereço ou outros campos opcionais cadastrados THEN o sistema exibe esses campos vazios no formulário

1.2 WHEN o `ProfileCubit` emite o estado `loaded` com os dados do membro THEN o sistema não preenche os controllers do formulário porque a flag `_controllersPopulated` foi marcada como `true` prematuramente durante o estado `loading`

1.3 WHEN a secretaria edita e salva o formulário com campos vazios (que deveriam estar pré-preenchidos) THEN o sistema sobrescreve os dados existentes do membro com valores em branco

### Expected Behavior (Correct)

2.1 WHEN a secretaria abre a tela de edição de um membro que possui dados cadastrados THEN o sistema SHALL pré-preencher todos os campos do formulário (nome, e-mail, CPF, telefone, data de nascimento, RG, sexo, estado civil, nome do pai, nome da mãe, endereço completo, datas eclesiásticas) com os valores existentes no banco de dados

2.2 WHEN o `ProfileCubit` emite o estado `loaded` com os dados do membro THEN o sistema SHALL preencher os controllers do formulário independentemente de quantas vezes o `BlocBuilder` tenha sido reconstruído antes desse estado

2.3 WHEN a secretaria abre a tela de edição e os dados são carregados com sucesso THEN o sistema SHALL garantir que a flag de preenchimento único (`_controllersPopulated`) só seja marcada como `true` após o preenchimento efetivo dos controllers, ou seja, somente quando o estado for `loaded`

### Unchanged Behavior (Regression Prevention)

3.1 WHEN a secretaria edita um campo já pré-preenchido e salva o formulário THEN o sistema SHALL CONTINUE TO persistir o novo valor informado pela secretaria, sem reverter para o valor original

3.2 WHEN a secretaria abre a tela de edição de um membro que não possui `MemberProfile` cadastrado (apenas `Membership`) THEN o sistema SHALL CONTINUE TO exibir os campos de dados pessoais pré-preenchidos com os dados do `User` e os campos de datas eclesiásticas vazios

3.3 WHEN a secretaria começa a digitar em um campo do formulário e o `BlocBuilder` reconstrói o widget por qualquer motivo THEN o sistema SHALL CONTINUE TO preservar o texto já digitado pela secretaria (comportamento de preenchimento único)

3.4 WHEN o carregamento dos dados do membro falha (erro de rede ou 404) THEN o sistema SHALL CONTINUE TO exibir a mensagem de erro correspondente sem travar a tela

3.5 WHEN a secretaria salva o formulário com sucesso THEN o sistema SHALL CONTINUE TO navegar de volta para a tela anterior e exibir o snackbar de confirmação

---

## Bug Condition (Pseudocódigo)

```pascal
FUNCTION isBugCondition(X)
  INPUT: X of type ProfileState
  OUTPUT: boolean

  // O bug ocorre quando _populateControllersOnce é chamado com estado
  // diferente de `loaded` E a flag _controllersPopulated ainda é false
  RETURN X is NOT ProfileState.loaded AND _controllersPopulated = false
END FUNCTION
```

```pascal
// Property: Fix Checking
FOR ALL X WHERE isBugCondition(X) DO
  // Após a transição para loaded, os controllers devem estar preenchidos
  result ← _populateControllersOnce(ProfileState.loaded(profile))
  ASSERT _nameController.text = profile.user.name
  ASSERT _cpfController.text = profile.user.cpf (when non-null)
  ASSERT _phoneController.text = profile.user.phone (when non-null)
  ASSERT _birthDateController.text = isoToDisplay(profile.birthDate) (when non-null)
  ASSERT _controllersPopulated = true
END FOR
```

```pascal
// Property: Preservation Checking
FOR ALL X WHERE NOT isBugCondition(X) DO
  // Quando o estado já é loaded desde o início (ex: testes com cubit pré-populado),
  // o preenchimento deve ocorrer normalmente na primeira chamada
  ASSERT F(X) = F'(X)
END FOR
```
