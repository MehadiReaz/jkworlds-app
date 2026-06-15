sealed class AppException implements Exception {
  final String message;
  final int? statusCode;
  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// No internet / connection timed out / socket error
class NetworkException extends AppException {
  const NetworkException(super.message);
}

/// Server responded with a 4xx/5xx we couldn't handle
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode});
}

/// 401 that survived a refresh attempt (or there was no token to refresh)
class AuthException extends AppException {
  const AuthException([super.message = 'Session expired. Please log in again.']);
}

/// Anything else we didn't anticipate
class UnknownException extends AppException {
  const UnknownException([super.message = 'An unexpected error occurred.']);
}