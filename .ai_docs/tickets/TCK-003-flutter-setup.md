# [Done] TCK-003: Setup do Frontend Flutter e Integrações (Mobile)

## Descrição
Bootstrapping do framework Flutter mobile, definição e criação de arquitetura de diretórios para Estado e Interface seguindo os designs de interfaces da stack previamente definida.
Implementação básica de layout de auth focada no login/recuperação conectando-se diretamente às rotas da API NestJS.

## Critérios de Aceite
- App Flutter instanciado sem erros base.
- Camada de autenticação da interface conectando com API.
- Testes E2E reais implementados.

## Logs de Execução
- [2026-04-01] Projeto Flutter criado em `atos_logos_mobile/` via `flutter create`.
- [2026-04-01] `pubspec.yaml` configurado com: `flutter_bloc`, `dio`, `get_it`, `injectable`, `go_router`, `freezed_annotation`, `flutter_secure_storage`, `bloc_test`, `mocktail`.
- [2026-04-01] `flutter pub upgrade --major-versions` executado com sucesso.
- [2026-04-01] Code generation (`dart run build_runner build`) concluído — 7 outputs gerados (freezed + json_serializable).
- [2026-04-01] Estrutura de feature-first criada em `lib/features/auth/`.
- [2026-04-01] `DioClient` configurado com `baseUrl: http://10.0.2.2:3000` e `AuthInterceptor`.
- [2026-04-01] `AuthRepository`, `AuthCubit`, `AuthState` (freezed) implementados.
- [2026-04-01] `LoginPage` implementada com UI dark premium, validação e estados de loading/erro.
- [2026-04-01] `integration_test/auth_flow_test.dart` criado com 2 cenários E2E.

## Decisões Técnicas
- Token JWT armazenado em `flutter_secure_storage` (criptografado no Keychain/Keystore).
- `DioClient` é Singleton — instância única compartilhada via `main.dart`.
- O `AuthInterceptor` injeta o Bearer Token automaticamente e limpa o storage em respostas 401.
- Os modelos `LoginRequest` e `AuthResponse` espelham exatamente os DTOs do backend NestJS.
- Home screen é um placeholder — será implementada no próximo ticket.

## Resultado dos Testes
- Code generation: ✅ `7 outputs` gerados sem erros.
- Testes E2E em `integration_test/auth_flow_test.dart`: requerem backend NestJS rodando + banco semeado.
  - `flutter test integration_test/auth_flow_test.dart` (executar com emulador Android ativo).
