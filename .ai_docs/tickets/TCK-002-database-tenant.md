# [Done] TCK-002: Base de Dados via Prisma e Tenant Architecture (Backend)

## Descrição
Criar e estruturar o contrato `schema.prisma` de maneira completa (além da base do Signup do TCK-001) contemplando o autorelacionamento da model `Congregation` para atender à lógica Sede/Filial.
Consolidar a inserção de `congregationId` nos domínios restantes. O arquivo Prisma serve como contrato único do repositório.

## Critérios de Aceite
- O schema está alinhado às estipulações em `.ai_docs/business_rules.md`, quando aplicável.
- Testes unitários e de integração para a proibição de criação de itens fora do isolamento de tenant passam com sucesso.

## Logs de Execução
- Ajustado `src/prisma/prisma.service.ts` para carregar `.env` explicitamente e inicializar o Prisma Client no formato compatível com a configuração gerada do Prisma 7.
- Corrigido `test/congregations.e2e-spec.ts` para subir a aplicação Nest completa com `ValidationPipe`, `JwtService`, guards e controllers reais, sobrescrevendo apenas o `PrismaService` com um provider em memória.
- Corrigido `src/modules/congregations/congregations.controller.spec.ts`, adicionando o mock de `CongregationsService` necessário para o controller compilar no teste unitário.
- O ambiente sandbox bloqueou a execução padrão do Jest com `spawn EPERM`, então a validação final foi executada com `--runInBand`.

## Decisões Técnicas
- O isolamento de tenant foi mantido: a criação de filial continua derivando `parentId` exclusivamente do JWT do usuário autenticado.
- O contrato de listagem foi mantido: `findAll` continua retornando a sede primeiro, seguida pelas filiais.
- Os E2E agora validam autenticação, validação global, fluxo HTTP e integração entre controller e service sem depender de PostgreSQL ativo no host local.
- O `PrismaService` foi atualizado para funcionar com a URL `prisma+postgres://` já presente na configuração atual do projeto.

## Resultado dos Testes
- `npx jest --runInBand` -> 4 suítes aprovadas, 11 testes aprovados.
- `npx jest --config ./test/jest-e2e.json test/congregations.e2e-spec.ts --runInBand` -> 1 suíte aprovada, 3 testes aprovados.
- Cenários validados no ticket:
- `POST /congregations/branch` sem autenticação -> `401`
- `POST /congregations/branch` com JWT -> `201` e `parentId === hqId`
- `GET /congregations` com JWT -> `200` com a sede na primeira posição
