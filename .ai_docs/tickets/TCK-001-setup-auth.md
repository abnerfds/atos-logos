# [Done] TCK-001: Setup NestJS e Autenticação (Backend)

## Descrição
Inicialização do projeto base da API com NestJS e configuração inicial do Prisma ORM (para PostgreSQL).
Estruturação da base em repositório raiz contendo o módulo específico `src/modules/auth` focado em gerenciar autenticação JWT/Passport (`@nestjs/jwt` e `@nestjs/passport`) para fluxos de Login e Signup para o admin (criador da Sede inicial).

## Critérios de Aceite
- O repositório NestJS base é inicializado com sucesso.
- O Prisma está configurado (`prisma/schema.prisma`) com o PostgreSQL ativo e os models User e Congregation estruturados em `db push`.
- O AuthModule encontra-se estruturado segundo a Arquitetura Layered Padrão do NestJS.
- Os testes Unitários para o fluxo de Token e Validação passam.
- Testes de Integração de API (testes de chamadas Supertest com banco de dados) do `/auth/login` e `/auth/signup` finalizam com Sucesso.

## Logs de Execução
- [2026-03-31] Ticket movido de To Do para In Progress, seguindo as diretrizes do novo roadmap system.
- [2026-03-31] Repositório NestJS gerado em `atos-logos-backend/`.
- [2026-03-31] Configuração do `docker-compose.yml` e Prisma finalizada com Tabela Congregation e User (isolamento garantido na engine).
- [2026-03-31] AuthModule construído em ciclo TDD utilizando `@nestjs/jwt` e `bcrypt` (senha cifrada).

## Decisões Técnicas
- O banco local deve ser um container Docker criado temporariamente.
- Mantidos testes E2E como jargão "Testes de Integração de API" conforme guideline arquitetônica.
- O AuthModule processa o Signup apenas para Administradores de forma inicial, registrando o nível hierárquico "Sede" na tabela preenchendo a FK de Sede com Nulo.

## Resultado dos Testes
```
 PASS  src/modules/auth/auth.service.spec.ts
  AuthService
    √ should be defined
    signupAdmin
      √ should create a Headquarters and an Admin if email does not exist
      √ should throw an error if the admin already exists
    login
      √ should return a jwt successfully when logging in a valid user
      √ should throw an error if the email does not exist
      √ should throw an error if the password is incorrect

Test Suites: 1 passed, 1 total
Tests:       6 passed, 6 total
```
