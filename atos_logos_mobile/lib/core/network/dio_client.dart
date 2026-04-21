import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  static Dio? _instance;

  static Dio getInstance({FlutterSecureStorage? storage}) {
    _instance ??= _createDio(storage ?? const FlutterSecureStorage());
    return _instance!;
  }

  static Dio _createDio(FlutterSecureStorage storage) {
    final baseOptions = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      contentType: 'application/json',
      responseType: ResponseType.json,
    );

    // A second Dio instance with NO auth interceptor. Used by the interceptor
    // itself to call /auth/refresh (avoiding recursion) and to retry the
    // original request with the freshly-rotated access token.
    final refreshDio = Dio(baseOptions);

    final dio = Dio(baseOptions);
    dio.interceptors.add(AuthInterceptor(storage, refreshDio));

    // Debug-only request/response logging. The `logPrint` closure is wired
    // up during DI bootstrap but is only ever invoked by the Dio runtime on
    // a real HTTP round-trip in debug builds — so the closure body never
    // runs from unit tests. It is documented as an intentional exclusion in
    // `tool/coverage_login.js` (exclusion map).
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }

    return dio;
  }
}
