import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/network/auth_interceptor.dart'
    show AuthInterceptor, kAuthRetryMarker;

class MockDio extends Mock implements Dio {}

class MockStorage extends Mock implements FlutterSecureStorage {}

class _FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeRequestOptions());
  });

  late MockDio refreshDio;
  late MockStorage storage;
  late AuthInterceptor interceptor;

  setUp(() {
    refreshDio = MockDio();
    storage = MockStorage();
    interceptor = AuthInterceptor(storage, refreshDio);
    when(() => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        )).thenAnswer((_) async {});
    when(() => storage.delete(key: any(named: 'key')))
        .thenAnswer((_) async {});
  });

  RequestOptions makeRequest(String path, {Map<String, dynamic>? extra}) {
    return RequestOptions(path: path, extra: extra ?? {});
  }

  DioException makeError(RequestOptions options, int? statusCode) {
    return DioException(
      requestOptions: options,
      response: statusCode == null
          ? null
          : Response<dynamic>(
              requestOptions: options,
              statusCode: statusCode,
            ),
    );
  }

  group('onRequest', () {
    test('adds Bearer token to Authorization header when access token exists',
        () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => 'stored-tkn');
      final options = makeRequest('/members');
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers['Authorization'], 'Bearer stored-tkn');
      expect(handler.continued, isTrue);
    });

    test('does not add header when no access token exists', () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => null);
      final options = makeRequest('/members');
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('does not attach Authorization to /auth/login requests', () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => 'stored-tkn');
      final options = makeRequest('/auth/login');
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });

    test('does not attach Authorization to /auth/refresh requests', () async {
      when(() => storage.read(key: 'access_token'))
          .thenAnswer((_) async => 'stored-tkn');
      final options = makeRequest('/auth/refresh');
      final handler = _RecordingRequestHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers.containsKey('Authorization'), isFalse);
    });
  });

  group('onError - 401 refresh flow', () {
    test(
        'refreshes token and retries original request when 401 is received on a protected endpoint',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'old-rfr');
      when(() => refreshDio.post('/auth/refresh', data: any(named: 'data')))
          .thenAnswer(
        (_) async => Response<dynamic>(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          statusCode: 200,
          data: {
            'access_token': 'new-acc',
            'refresh_token': 'new-rfr',
          },
        ),
      );
      when(() => refreshDio.fetch(any())).thenAnswer(
        (invocation) async => Response<dynamic>(
          requestOptions: invocation.positionalArguments.first as RequestOptions,
          statusCode: 200,
          data: {'ok': true},
        ),
      );

      final failedOptions = makeRequest('/members');
      final error = makeError(failedOptions, 401);
      final handler = _RecordingErrorHandler();

      await interceptor.onError(error, handler);

      // Should persist new tokens
      verify(() => storage.write(key: 'access_token', value: 'new-acc'))
          .called(1);
      verify(() => storage.write(key: 'refresh_token', value: 'new-rfr'))
          .called(1);
      // Should retry with the new token and resolve
      expect(handler.resolvedResponse?.data, {'ok': true});
      final retryCapture =
          verify(() => refreshDio.fetch(captureAny())).captured.single
              as RequestOptions;
      expect(retryCapture.headers['Authorization'], 'Bearer new-acc');
    });

    test('clears tokens and propagates when no refresh token is stored',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => null);

      final failedOptions = makeRequest('/members');
      final handler = _RecordingErrorHandler();
      await interceptor.onError(makeError(failedOptions, 401), handler);

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
      expect(handler.propagated, isTrue);
    });

    test('clears tokens and propagates when refresh call itself fails',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'dead-rfr');
      when(() => refreshDio.post('/auth/refresh', data: any(named: 'data')))
          .thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/auth/refresh'),
          response: Response<dynamic>(
            requestOptions: RequestOptions(path: '/auth/refresh'),
            statusCode: 401,
          ),
        ),
      );

      final failedOptions = makeRequest('/members');
      final handler = _RecordingErrorHandler();
      await interceptor.onError(makeError(failedOptions, 401), handler);

      verify(() => storage.delete(key: 'access_token')).called(1);
      verify(() => storage.delete(key: 'refresh_token')).called(1);
      expect(handler.propagated, isTrue);
    });

    test('does not attempt refresh when the failing request is /auth/refresh',
        () async {
      final failedOptions = makeRequest('/auth/refresh');
      final handler = _RecordingErrorHandler();

      await interceptor.onError(makeError(failedOptions, 401), handler);

      verifyNever(
        () => refreshDio.post('/auth/refresh', data: any(named: 'data')),
      );
      expect(handler.propagated, isTrue);
    });

    test('does not attempt refresh when the failing request is /auth/login',
        () async {
      final failedOptions = makeRequest('/auth/login');
      final handler = _RecordingErrorHandler();

      await interceptor.onError(makeError(failedOptions, 401), handler);

      verifyNever(
        () => refreshDio.post('/auth/refresh', data: any(named: 'data')),
      );
      expect(handler.propagated, isTrue);
    });

    test('only retries once — marks the request to prevent infinite loops',
        () async {
      when(() => storage.read(key: 'refresh_token'))
          .thenAnswer((_) async => 'rfr');
      final alreadyRetried =
          makeRequest('/members', extra: {kAuthRetryMarker: true});
      final handler = _RecordingErrorHandler();

      await interceptor.onError(makeError(alreadyRetried, 401), handler);

      verifyNever(
        () => refreshDio.post('/auth/refresh', data: any(named: 'data')),
      );
      verify(() => storage.delete(key: 'access_token')).called(1);
      expect(handler.propagated, isTrue);
    });

    test('propagates non-401 errors without touching storage', () async {
      final failedOptions = makeRequest('/members');
      final handler = _RecordingErrorHandler();

      await interceptor.onError(makeError(failedOptions, 500), handler);

      verifyNever(() => storage.read(key: any(named: 'key')));
      verifyNever(() => storage.delete(key: any(named: 'key')));
      expect(handler.propagated, isTrue);
    });
  });
}

/// Records whether `handler.next` was called. Interceptor tests need this
/// because mocktail cannot mock the sealed Dio handler classes directly.
class _RecordingRequestHandler extends RequestInterceptorHandler {
  bool continued = false;

  @override
  void next(RequestOptions requestOptions) {
    continued = true;
  }
}

class _RecordingErrorHandler extends ErrorInterceptorHandler {
  bool propagated = false;
  Response<dynamic>? resolvedResponse;

  @override
  void next(DioException err) {
    propagated = true;
  }

  @override
  void resolve(Response<dynamic> response, [bool callFollowingResponseInterceptor = false]) {
    resolvedResponse = response;
  }
}
