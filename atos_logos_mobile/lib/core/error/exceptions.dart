/// Base exception for all application errors.
class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when a network/API request fails.
class NetworkException extends AppException {
  final int? statusCode;
  NetworkException(super.message, {this.statusCode});
}

/// Thrown for authentication-specific errors (401, 403).
class AuthException extends AppException {
  AuthException(super.message);
}
