# O Produto e o MVP (Atos Logos)

## Escopo do MVP
O Produto Mínimo Viável foca exclusivamente no módulo de Autenticação com os seguintes recursos:
- **Signup:** Criação de conta permitida apenas para perfis criados como o administrador `Admin`.
- **Login:** Autenticação padrão de usuários no sistema.
- **Recuperação de Senha:** Fluxo para resetar a senha de acesso.
- **Sessão Persistente:** Manutenção do estado de login de forma segura e duradoura.

## Base de Dados Central (Isolamento de Tenant)
A estrutura base para suportar o modelo Multi-tenant na gestão eclesiástica deve possuir as seguintes regras nas entidades centrais:

- **Tabela `congregations` (Congregações):**
  - Utiliza esquema de autorelacionamento.
  - O campo `parent_id` deve ser preenchido como `null` para referenciar a igreja Sede principal.
  - O campo `parent_id` deve conter o ID da Sede correspondente para as igrejas Filiais.

- **Tabela `users` (Usuários):**
  - O campo `congregation_id` é estritamente **obrigatório**. 
  - Este vínculo é a base do isolamento, garantindo que usuários possuam acesso restrito e isolado exclusivamente aos dados do Tenant de sua congregação.
