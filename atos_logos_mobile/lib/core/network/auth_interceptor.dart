import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'session_expired_notifier.dart';

/// Keys kept here (not imported from the auth feature) so this core
/// infrastructure file does not reach into a feature folder.
const String _kAccessTokenKey = 'access_token';
const String _kRefreshTokenKey = 'refresh_token';

/// Paths that are exempt from the Authorization header (they are the
/// credential-exchange endpoints themselves).
const Set<String> _kAuthPaths = {
  '/auth/login',
  '/auth/refresh',
  '/auth/logout',
  '/auth/signup-admin',
  '/auth/select-church',
};

/// Marker placed in `RequestOptions.extra` after a single retry so that a
/// second 401 does not trigger another refresh (prevents loops). Exported
/// for tests that need to simulate an already-retried request.
const String kAuthRetryMarker = '_authRetried';

/// Attaches the access token to outgoing requests and transparently
/// refreshes it when the server returns 401.
///
/// Uses a separate "refresh" Dio instance (without this interceptor) to
/// perform the refresh call and retry the original request so we never
/// recurse through ourselves.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;
  final Dio _refreshDio;
  final SessionExpiredNotifier _sessionNotifier;

  AuthInterceptor(this._storage, this._refreshDio, this._sessionNotifier);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isAuthPath(options.path)) {
      handler.next(options);
      return;
    }

    final token = await _storage.read(key: _kAccessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // Only 401s on protected endpoints trigger the refresh dance.
    if (statusCode != 401 || _isAuthPath(path)) {
      handler.next(err);
      return;
    }

    // Already retried once — give up and clear the session.
    if (err.requestOptions.extra[kAuthRetryMarker] == true) {
      await _clearTokens();
      handler.next(err);
      return;
    }

    final refreshToken = await _storage.read(key: _kRefreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      await _clearTokens();
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await _refreshDio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      final data = refreshResponse.data as Map<String, dynamic>;
      final newAccess = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String;
      await _storage.write(key: _kAccessTokenKey, value: newAccess);
      await _storage.write(key: _kRefreshTokenKey, value: newRefresh);

      // Retry the original request with the new token on the refresh Dio
      // so the new request does not go through this interceptor again.
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';
      retryOptions.extra[kAuthRetryMarker] = true;
      final retryResponse = await _refreshDio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      // Refresh failed — the session is dead. Clear locally and propagate
      // the original 401 so the UI can react (e.g., redirect to login).
      await _clearTokens();
      handler.next(err);
    }
  }

  bool _isAuthPath(String path) {
    for (final prefix in _kAuthPaths) {
      if (path.startsWith(prefix)) return true;
    }
    return false;
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: _kAccessTokenKey);
    await _storage.delete(key: _kRefreshTokenKey);
    _sessionNotifier.notifySessionExpired();
  }
}
