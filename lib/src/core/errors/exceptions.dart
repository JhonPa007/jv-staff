class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException(this.message, {this.statusCode});
  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  CacheException(this.message);
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
