# Regras de Arquitetura e Padrões (Atos Logos)

## Stack Tecnológico Base
- **Backend:** Node.js, NestJS (API RESTful), PostgreSQL, Prisma ORM.
- **Frontend:** Flutter (Mobile). Layouts via Google Snitch.

## Backend (NestJS)
- **Arquitetura Padrão do NestJS (Layered Architecture).** A lógica deve residir nos Services e o roteamento/validação nos Controllers. O agrupamento será feito pelos Modules nativos do framework.
- **TypeScript Estrito:** É EXPRESSAMENTE PROIBIDO o uso de `any` ou `unknown` nos payloads de Controllers. Toda entrada de dados DEVE ser tipada usando DTOs validados com `class-validator` e `class-transformer`.
- **Obrigatoriedade:** Cada domínio (como Auth, Tenant e Member) terá seu próprio Module, Controller e Service no NestJS.
  - *Exemplos de Módulos:* `src/modules/auth`, `src/modules/tenant`.

## Frontend (Flutter)
- **Gerenciamento de Estado:** Obrigatório o uso de `flutter_bloc` (Cubit para estados simples, Bloc para fluxos complexos). 
- **Network/API:** Uso exclusivo da biblioteca `dio`. Configurar Interceptors para gerenciar o Bearer Token JWT e erros de 401 (Unauthorized).
- **Modelagem de Dados:** Uso de `freezed` e `json_serializable` para garantir imutabilidade e tipagem estrita (Zero `dynamic` em lógica de negócio).
- **Separação de Preocupações:** Arquitetura baseada em **Features**. Cada feature deve ter subpastas `/data`, `/domain` e `/presentation`.
- **Injeção de Dependência:** Utilizar `get_it` para gerenciar instâncias de Repositories e Services.
