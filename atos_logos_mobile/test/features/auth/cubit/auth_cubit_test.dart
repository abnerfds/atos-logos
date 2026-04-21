import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/auth/data/auth_repository.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/auth_response.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/church_option.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/login_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/select_church_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/signup_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/user_profile.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:atos_logos_mobile/features/auth/presentation/cubit/auth_state.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class _FakeLoginRequest extends Fake implements LoginRequest {}

class _FakeSelectChurchRequest extends Fake implements SelectChurchRequest {}

class _FakeSignupRequest extends Fake implements SignupRequest {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeLoginRequest());
    registerFallbackValue(_FakeSelectChurchRequest());
    registerFallbackValue(_FakeSignupRequest());
  });

  late MockAuthRepository repository;

  setUp(() {
    repository = MockAuthRepository();
  });

  AuthCubit buildCubit() => AuthCubit(repository: repository);

  const singleChurch = ChurchOption(
    id: 'c1',
    name: 'Grace Church',
    branchName: 'HQ',
    role: 'ADMIN',
  );

  group('AuthCubit - initial state', () {
    test('starts in initial state', () {
      expect(buildCubit().state, const AuthState.initial());
    });
  });

  group('AuthCubit - login', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when repository returns LoginSuccess',
      build: () {
        when(() => repository.login(any())).thenAnswer(
          (_) async => LoginSuccess(
            const AuthResponse(accessToken: 'tkn-123', refreshToken: 'rfr-123'),
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: 'a@b.com', password: 'pwd123'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, churchSelection] when repository returns LoginChurchSelection',
      build: () {
        when(() => repository.login(any())).thenAnswer(
          (_) async => LoginChurchSelection(
            selectionToken: 'sel-tkn',
            churches: const [singleChurch],
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: 'a@b.com', password: 'pwd123'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.churchSelection(
          selectionToken: 'sel-tkn',
          churches: [singleChurch],
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] with AppException message on NetworkException',
      build: () {
        when(() => repository.login(any()))
            .thenThrow(NetworkException('Credenciais inválidas'));
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: 'a@b.com', password: 'pwd'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Credenciais inválidas'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] with "Erro inesperado" on generic exception',
      build: () {
        when(() => repository.login(any())).thenThrow(Exception('boom'));
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: 'a@b.com', password: 'pwd'),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Erro inesperado'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'forwards email and password to repository as LoginRequest',
      build: () {
        when(() => repository.login(any())).thenAnswer(
          (_) async => LoginSuccess(const AuthResponse(accessToken: 't', refreshToken: 'r')),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.login(email: 'user@test.com', password: 'pwd123'),
      verify: (_) {
        final captured =
            verify(() => repository.login(captureAny())).captured;
        final request = captured.single as LoginRequest;
        expect(request.email, 'user@test.com');
        expect(request.password, 'pwd123');
      },
    );
  });

  group('AuthCubit - selectChurch', () {
    blocTest<AuthCubit, AuthState>(
      'emits error when called without a prior selection token',
      build: () => buildCubit(),
      act: (cubit) => cubit.selectChurch('c1'),
      expect: () => [
        const AuthState.error(message: 'No selection token available'),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] when selection succeeds after login stored token',
      build: () {
        when(() => repository.login(any())).thenAnswer(
          (_) async => LoginChurchSelection(
            selectionToken: 'sel-tkn',
            churches: const [singleChurch],
          ),
        );
        when(() => repository.selectChurch(any())).thenAnswer(
          (_) async => const AuthResponse(accessToken: 'final-tkn', refreshToken: 'final-rfr'),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.login(email: 'a@b.com', password: 'pwd');
        await cubit.selectChurch('c1');
      },
      skip: 2,
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] when selectChurch throws',
      build: () {
        when(() => repository.login(any())).thenAnswer(
          (_) async => LoginChurchSelection(
            selectionToken: 'sel-tkn',
            churches: const [singleChurch],
          ),
        );
        when(() => repository.selectChurch(any())).thenThrow(
          NetworkException('Sem vínculo ativo nesta igreja'),
        );
        return buildCubit();
      },
      act: (cubit) async {
        await cubit.login(email: 'a@b.com', password: 'pwd');
        await cubit.selectChurch('c1');
      },
      skip: 2,
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(message: 'Sem vínculo ativo nesta igreja'),
      ],
    );
  });

  group('AuthCubit - signup', () {
    blocTest<AuthCubit, AuthState>(
      'emits [loading, authenticated] on success — auto-login after signup',
      build: () {
        when(() => repository.signup(any())).thenAnswer(
          (_) async => const AuthResponse(
            accessToken: 'new-acc',
            refreshToken: 'new-rfr',
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.signup(
        name: 'N',
        email: 'a@b.com',
        password: 'pwd123',
        churchName: 'C',
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.authenticated(),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [loading, error] with translated message when signup throws',
      build: () {
        when(() => repository.signup(any())).thenThrow(
          NetworkException('Já existe um usuário com este e-mail.'),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.signup(
        name: 'N',
        email: 'a@b.com',
        password: 'pwd123',
        churchName: 'C',
      ),
      expect: () => [
        const AuthState.loading(),
        const AuthState.error(
          message: 'Já existe um usuário com este e-mail.',
        ),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'forwards name, email, password and churchName to repository.signup',
      build: () {
        when(() => repository.signup(any())).thenAnswer(
          (_) async => const AuthResponse(
            accessToken: 't',
            refreshToken: 'r',
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.signup(
        name: 'Pastor John',
        email: 'pastor@church.com',
        password: 'password123',
        churchName: 'Grace Church',
      ),
      verify: (_) {
        final captured =
            verify(() => repository.signup(captureAny())).captured;
        final request = captured.single as SignupRequest;
        expect(request.name, 'Pastor John');
        expect(request.email, 'pastor@church.com');
        expect(request.password, 'password123');
        expect(request.churchName, 'Grace Church');
      },
    );
  });

  group('AuthCubit - logout', () {
    blocTest<AuthCubit, AuthState>(
      'calls repository.logout and emits initial',
      build: () {
        when(() => repository.logout()).thenAnswer((_) async {});
        return buildCubit();
      },
      seed: () => const AuthState.authenticated(),
      act: (cubit) => cubit.logout(),
      expect: () => [const AuthState.initial()],
      verify: (_) {
        verify(() => repository.logout()).called(1);
      },
    );
  });

  group('AuthCubit - checkAuthStatus', () {
    blocTest<AuthCubit, AuthState>(
      'emits authenticated when token exists and refresh succeeds',
      build: () {
        when(() => repository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => repository.refresh()).thenAnswer(
          (_) async => const AuthResponse(
            accessToken: 'new-acc',
            refreshToken: 'new-rfr',
          ),
        );
        return buildCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [const AuthState.authenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'stays silent when no persisted token exists',
      build: () {
        when(() => repository.isAuthenticated())
            .thenAnswer((_) async => false);
        return buildCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => <AuthState>[],
    );

    blocTest<AuthCubit, AuthState>(
      'stays silent when refresh fails (session is dead)',
      build: () {
        when(() => repository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => repository.refresh())
            .thenThrow(AuthException('Sessão expirada. Faça login novamente.'));
        return buildCubit();
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => <AuthState>[],
    );
  });

  group('AuthCubit - fetchProfile', () {
    const profile = UserProfile(
      user: UserProfileUser(id: 'u1', name: 'Ana', email: 'a@b.com'),
      membership: UserProfileMembership(role: 'ADMIN', status: 'ACTIVE'),
      positions: [],
      church: UserProfileChurch(id: 'c1', name: 'Grace'),
      branch: UserProfileBranch(id: 'b1', name: 'HQ'),
    );

    blocTest<AuthCubit, AuthState>(
      'emits authenticated with profile on success',
      build: () {
        when(() => repository.getProfile())
            .thenAnswer((_) async => profile);
        return buildCubit();
      },
      act: (cubit) => cubit.fetchProfile(),
      expect: () => [const AuthState.authenticated(profile: profile)],
    );

    blocTest<AuthCubit, AuthState>(
      'emits authenticated without profile when profile fetch fails (session preserved)',
      build: () {
        when(() => repository.getProfile())
            .thenThrow(NetworkException('fail'));
        return buildCubit();
      },
      act: (cubit) => cubit.fetchProfile(),
      expect: () => [const AuthState.authenticated()],
    );
  });
}
