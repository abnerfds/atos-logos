import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/error/exceptions.dart';
import 'package:atos_logos_mobile/features/auth/data/auth_repository.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/login_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/select_church_request.dart';
import 'package:atos_logos_mobile/features/auth/domain/models/signup_request.dart';

class MockDio extends Mock implements Dio {}

class MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockDio dio;
  late MockStorage storage;
  late AuthRepository repository;

  setUp(() {
    dio = MockDio();
    storage = MockStorage();
    repository = AuthRepository(dio: dio, storage: storage);
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
    when(() => storage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);
  });

  Response<dynamic> fakeResponse(dynamic data, {int statusCode = 200}) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: ''),
      data: data,
      statusCode: statusCode,
    );
  }

  DioException dioFailure({
    int? statusCode,
    dynamic data,
    DioExceptionType type = DioExceptionType.badResponse,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: ''),
      type: type,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: RequestOptions(path: ''),
              statusCode: statusCode,
              data: data,
            ),
    );
  }

  group('login', () {
    test(
        'returns LoginSuccess and persists both access and refresh tokens for single membership',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => fakeResponse({
          'access_token': 'tkn-123',
          'refresh_token': 'rfr-456',
        }),
      );

      final result = await repository.login(
        const LoginRequest(email: 'a@b.com', password: 'pwd123'),
      );

      expect(result, isA<LoginSuccess>());
      final success = result as LoginSuccess;
      expect(success.response.accessToken, 'tkn-123');
      expect(success.response.refreshToken, 'rfr-456');
      verify(() => storage.write(key: 'access_token', value: 'tkn-123'))
          .called(1);
      verify(() => storage.write(key: 'refresh_token', value: 'rfr-456'))
          .called(1);
    });

    test('returns LoginChurchSelection without persisting token for multi-church',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => fakeResponse({
          'requiresChurchSelection': true,
          'selectionToken': 'sel-tkn',
          'churches': [
            {
              'id': 'c1',
              'name': 'Grace',
              'branchName': 'HQ',
              'role': 'ADMIN',
            },
          ],
        }),
      );

      final result = await repository.login(
        const LoginRequest(email: 'a@b.com', password: 'pwd123'),
      );

      expect(result, isA<LoginChurchSelection>());
      final selection = result as LoginChurchSelection;
      expect(selection.selectionToken, 'sel-tkn');
      expect(selection.churches, hasLength(1));
      expect(selection.churches.first.name, 'Grace');
      verifyNever(() => storage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ));
    });

    test('maps 401 Invalid credentials to PT-BR "Credenciais inválidas"',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioFailure(statusCode: 401, data: {'message': 'Invalid credentials'}),
      );

      await expectLater(
        repository.login(
          const LoginRequest(email: 'a@b.com', password: 'pwd'),
        ),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.message, 'message', 'Credenciais inválidas')
              .having((e) => e.statusCode, 'statusCode', 401),
        ),
      );
    });

    test(
        'maps 401 "No active membership found" to "Credenciais inválidas" (prevents user enumeration)',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioFailure(
          statusCode: 401,
          data: {'message': 'No active membership found'},
        ),
      );

      await expectLater(
        repository.login(
          const LoginRequest(email: 'a@b.com', password: 'pwd'),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Credenciais inválidas',
          ),
        ),
      );
    });

    test('maps connection timeout to PT-BR connectivity message', () async {
      when(() => dio.post(any(), data: any(named: 'data')))
          .thenThrow(dioFailure(type: DioExceptionType.connectionTimeout));

      await expectLater(
        repository.login(
          const LoginRequest(email: 'a@b.com', password: 'pwd'),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Sem conexão. Verifique sua internet.',
          ),
        ),
      );
    });

    test('maps 500 response to PT-BR server error message', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioFailure(statusCode: 500, data: {'message': 'Internal'}),
      );

      await expectLater(
        repository.login(
          const LoginRequest(email: 'a@b.com', password: 'pwd'),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Erro no servidor. Tente novamente.',
          ),
        ),
      );
    });
  });

  group('selectChurch', () {
    test('returns AuthResponse and persists both tokens on success',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => fakeResponse({
          'access_token': 'final-tkn',
          'refresh_token': 'final-rfr',
        }),
      );

      final result = await repository.selectChurch(
        const SelectChurchRequest(
          selectionToken: 'sel',
          churchId: 'c1',
        ),
      );

      expect(result.accessToken, 'final-tkn');
      expect(result.refreshToken, 'final-rfr');
      verify(() => storage.write(key: 'access_token', value: 'final-tkn'))
          .called(1);
      verify(() => storage.write(key: 'refresh_token', value: 'final-rfr'))
          .called(1);
    });

    test('maps "Invalid or expired selection token" to PT-BR', () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioFailure(
          statusCode: 401,
          data: {'message': 'Invalid or expired selection token'},
        ),
      );

      await expectLater(
        repository.selectChurch(
          const SelectChurchRequest(selectionToken: 's', churchId: 'c1'),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Sessão expirada. Faça login novamente.',
          ),
        ),
      );
    });
  });

  group('signup', () {
    test(
        'POSTs to /auth/signup-admin and persists the auto-issued token pair',
        () async {
      // Given — the backend returns an access + refresh token pair
      // (the new auto-login behavior of /auth/signup-admin)
      when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => fakeResponse({
          'access_token': 'sig-acc',
          'refresh_token': 'sig-rfr',
        }),
      );

      // When — signup is called
      final result = await repository.signup(
        const SignupRequest(
          name: 'N',
          email: 'a@b.com',
          password: 'pwd123',
          churchName: 'C',
        ),
      );

      // Then — the right endpoint is hit
      verify(() => dio.post('/auth/signup-admin', data: any(named: 'data')))
          .called(1);
      // Both tokens are returned to the cubit
      expect(result.accessToken, 'sig-acc');
      expect(result.refreshToken, 'sig-rfr');
      // Both tokens are persisted in secure storage
      verify(() => storage.write(key: 'access_token', value: 'sig-acc'))
          .called(1);
      verify(() => storage.write(key: 'refresh_token', value: 'sig-rfr'))
          .called(1);
    });

    test('maps email conflict to PT-BR "Já existe um usuário com este e-mail"',
        () async {
      when(() => dio.post(any(), data: any(named: 'data'))).thenThrow(
        dioFailure(
          statusCode: 400,
          data: {'message': 'A user with this email already exists'},
        ),
      );

      await expectLater(
        repository.signup(
          const SignupRequest(
            name: 'N',
            email: 'a@b.com',
            password: 'pwd',
            churchName: 'C',
          ),
        ),
        throwsA(
          isA<NetworkException>().having(
            (e) => e.message,
            'message',
            'Já existe um usuário com este e-mail.',
          ),
        ),
      );
    });
  });

  group('logout', () {
    test('deletes both access_token and refresh_token from secure storage',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'some-rfr');
      when(() => dio.post('/auth/logout', data: any(named: 'data')))
          .thenAnswer((_) async => fakeResponse(null, statusCode: 204));

      await repository.logout();

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
    });

    test('calls backend /auth/logout with stored refresh token to revoke it',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'stored-rfr');
      when(() => dio.post('/auth/logout', data: any(named: 'data')))
          .thenAnswer((_) async => fakeResponse(null, statusCode: 204));

      await repository.logout();

      verify(() => dio.post(
            '/auth/logout',
            data: {'refreshToken': 'stored-rfr'},
          )).called(1);
    });

    test(
        'silently clears local tokens when backend logout call fails (e.g. offline)',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'stored-rfr');
      when(() => dio.post('/auth/logout', data: any(named: 'data')))
          .thenThrow(dioFailure(type: DioExceptionType.connectionTimeout));

      // Must NOT throw — logout is best-effort on the backend,
      // local clean-up is what matters.
      await repository.logout();

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
    });
  });

  group('refresh', () {
    test(
        'POSTs stored refresh token and persists new pair when rotation succeeds',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'old-rfr');
      when(() => dio.post('/auth/refresh', data: any(named: 'data')))
          .thenAnswer(
        (_) async => fakeResponse({
          'access_token': 'new-acc',
          'refresh_token': 'new-rfr',
        }),
      );

      final result = await repository.refresh();

      expect(result.accessToken, 'new-acc');
      expect(result.refreshToken, 'new-rfr');
      verify(() => dio.post(
            '/auth/refresh',
            data: {'refreshToken': 'old-rfr'},
          )).called(1);
      verify(() => storage.write(key: 'access_token', value: 'new-acc'))
          .called(1);
      verify(() => storage.write(key: 'refresh_token', value: 'new-rfr'))
          .called(1);
    });

    test('throws AuthException when no refresh token is stored', () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);

      await expectLater(
        repository.refresh(),
        throwsA(isA<AuthException>()),
      );
    });

    test(
        'clears stored tokens when backend rejects the refresh (401) — session is dead',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'compromised-rfr');
      when(() => dio.post('/auth/refresh', data: any(named: 'data'))).thenThrow(
        dioFailure(
          statusCode: 401,
          data: {'message': 'Refresh token reuse detected'},
        ),
      );

      await expectLater(
        repository.refresh(),
        throwsA(isA<AuthException>()),
      );
      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
    });
  });

  group('isAuthenticated', () {
    test('returns true when a non-empty token is stored', () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => 'tkn');
      expect(await repository.isAuthenticated(), isTrue);
    });

    test('returns false when token is null', () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => null);
      expect(await repository.isAuthenticated(), isFalse);
    });

    test('returns false when token is empty string', () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => '');
      expect(await repository.isAuthenticated(), isFalse);
    });
  });

  group('getProfile', () {
    test('returns UserProfile on success', () async {
      when(() => dio.get(any())).thenAnswer(
        (_) async => fakeResponse({
          'user': {'id': 'u1', 'name': 'Ana', 'email': 'a@b.com'},
          'membership': {'role': 'ADMIN', 'status': 'ACTIVE'},
          'positions': <dynamic>[],
          'church': {'id': 'c1', 'name': 'Grace'},
          'branch': {'id': 'b1', 'name': 'HQ'},
          'profile': null,
        }),
      );

      final profile = await repository.getProfile();
      expect(profile.user.name, 'Ana');
      expect(profile.church.name, 'Grace');
    });

    test('throws NetworkException on DioException', () async {
      when(() => dio.get(any())).thenThrow(dioFailure(statusCode: 500));
      await expectLater(
        repository.getProfile(),
        throwsA(isA<NetworkException>()),
      );
    });
  });
}
