import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:atos_logos_mobile/core/constants/api_constants.dart';
import 'package:atos_logos_mobile/core/network/auth_interceptor.dart';
import 'package:atos_logos_mobile/core/network/dio_client.dart';

class MockStorage extends Mock implements FlutterSecureStorage {}

void main() {
  group('DioClient - getInstance', () {
    test(
        'should return a Dio instance configured with the backend base URL and timeouts',
        () {
      // Given — a stub secure storage
      final storage = MockStorage();

      // When — a Dio is requested from the client
      final dio = DioClient.getInstance(storage: storage);

      // Then — the base options match the ApiConstants the app ships with
      expect(dio, isA<Dio>());
      expect(dio.options.baseUrl, ApiConstants.baseUrl);
      expect(dio.options.connectTimeout, ApiConstants.connectTimeout);
      expect(dio.options.receiveTimeout, ApiConstants.receiveTimeout);
      expect(dio.options.contentType, 'application/json');
    });

    test(
        'should attach the AuthInterceptor so outgoing requests get the bearer token',
        () {
      // Given — a storage stub
      final storage = MockStorage();

      // When — the Dio is built
      final dio = DioClient.getInstance(storage: storage);

      // Then — at least one of the interceptors is an AuthInterceptor
      final hasAuth = dio.interceptors.any((i) => i is AuthInterceptor);
      expect(hasAuth, isTrue);
    });

    test(
        'should cache the Dio instance and return the same singleton on subsequent calls',
        () {
      // Given — one call seeds the singleton
      final storage = MockStorage();
      final first = DioClient.getInstance(storage: storage);

      // When — a second call is made
      final second = DioClient.getInstance(storage: storage);

      // Then — the exact same instance is returned (identity, not equality)
      expect(identical(first, second), isTrue);
    });
  });
}
