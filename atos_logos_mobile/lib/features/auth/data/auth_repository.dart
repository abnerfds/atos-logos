import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/exceptions.dart';
import '../domain/models/auth_response.dart';
import '../domain/models/church_option.dart';
import '../domain/models/login_request.dart';
import '../domain/models/select_church_request.dart';
import '../domain/models/signup_request.dart';
import '../domain/models/user_profile.dart';

/// Represents the result of a login attempt.
/// Either a direct token (single membership) or a list of churches to choose from.
sealed class LoginResult {}

class LoginSuccess extends LoginResult {
  final AuthResponse response;
  LoginSuccess(this.response);
}

class LoginChurchSelection extends LoginResult {
  final String selectionToken;
  final List<ChurchOption> churches;
  LoginChurchSelection({required this.selectionToken, required this.churches});
}

/// Maps known backend English error messages to user-facing PT-BR.
/// Unknown messages fall through to a generic PT-BR default.
const Map<String, String> _ptBrErrorMessages = {
  'Invalid credentials': 'Credenciais inválidas',
  // Prevent user enumeration: same message as invalid credentials.
  'No active membership found': 'Credenciais inválidas',
  'No active membership for this church': 'Sem vínculo ativo nesta igreja.',
  'Invalid or expired selection token':
      'Sessão expirada. Faça login novamente.',
  'Invalid token type': 'Token inválido.',
  'A user with this email already exists':
      'Já existe um usuário com este e-mail.',
  'A user with this phone already exists':
      'Já existe um usuário com este telefone.',
};

NetworkException _translateDioException(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final serverMessage = (data is Map<String, dynamic>)
      ? data['message'] as String?
      : null;

  // Connectivity failures (no response reached the client).
  if (e.response == null ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout ||
      e.type == DioExceptionType.connectionError) {
    return NetworkException(
      'Sem conexão. Verifique sua internet.',
      statusCode: statusCode,
    );
  }

  // Server-side failures.
  if (statusCode != null && statusCode >= 500) {
    return NetworkException(
      'Erro no servidor. Tente novamente.',
      statusCode: statusCode,
    );
  }

  // Known backend message → PT-BR translation.
  final translated = _ptBrErrorMessages[serverMessage];
  if (translated != null) {
    return NetworkException(translated, statusCode: statusCode);
  }

  // Fall back to the server-provided message or a generic one.
  return NetworkException(
    serverMessage ?? 'Erro inesperado. Tente novamente.',
    statusCode: statusCode,
  );
}

/// Secure-storage keys for the authenticated session. Centralized so both
/// the repository and the network interceptor agree on the layout.
const String kAccessTokenKey = 'access_token';
const String kRefreshTokenKey = 'refresh_token';

@lazySingleton
class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository({required Dio dio, required FlutterSecureStorage storage})
      : _dio = dio,
        _storage = storage;

  Future<LoginResult> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;

      if (data['requiresChurchSelection'] == true) {
        final churches = (data['churches'] as List)
            .map((c) => ChurchOption.fromJson(c as Map<String, dynamic>))
            .toList();
        return LoginChurchSelection(
          selectionToken: data['selectionToken'] as String,
          churches: churches,
        );
      }

      final authResponse = AuthResponse.fromJson(data);
      await _persistTokens(authResponse);
      return LoginSuccess(authResponse);
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  Future<AuthResponse> selectChurch(SelectChurchRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/select-church',
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _persistTokens(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  /// Exchanges the persisted refresh token for a new access+refresh pair.
  /// Rotates the refresh token server-side. On 4xx, clears local tokens so
  /// the caller is forced back to the login screen.
  Future<AuthResponse> refresh() async {
    final current = await _storage.read(key: kRefreshTokenKey);
    if (current == null || current.isEmpty) {
      throw AuthException('Sessão expirada. Faça login novamente.');
    }

    try {
      final response = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': current},
      );
      final authResponse = AuthResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
      await _persistTokens(authResponse);
      return authResponse;
    } on DioException catch (e) {
      // Any refresh failure is fatal: the stored session is either invalid,
      // expired, or has been revoked due to reuse detection. Clear locally
      // so the app reflects the server state.
      await _clearTokens();
      throw AuthException(
        _translateDioException(e).message,
      );
    }
  }

  /// Creates the church + admin and persists the auto-issued token pair
  /// returned by the backend so the new admin is logged in immediately.
  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/signup-admin',
        data: request.toJson(),
      );
      final data = response.data as Map<String, dynamic>;
      final authResponse = AuthResponse.fromJson(data);
      await _persistTokens(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  /// Best-effort logout: attempts to revoke the refresh token on the backend
  /// and always clears local storage, even if the network call fails.
  Future<void> logout() async {
    final refreshToken = await _storage.read(key: kRefreshTokenKey);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } on DioException {
        // Swallowed on purpose: the user's expectation is that "logout"
        // clears their session locally regardless of connectivity.
      }
    }
    await _clearTokens();
  }

  Future<bool> isAuthenticated() async {
    final token = await _storage.read(key: kAccessTokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get('/auth/me');
      return UserProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _translateDioException(e);
    }
  }

  Future<void> _persistTokens(AuthResponse response) async {
    await _storage.write(key: kAccessTokenKey, value: response.accessToken);
    await _storage.write(key: kRefreshTokenKey, value: response.refreshToken);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: kAccessTokenKey);
    await _storage.delete(key: kRefreshTokenKey);
  }
}
