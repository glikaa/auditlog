/// Typed exceptions thrown by data sources.
/// These are caught at the repository boundary and mapped to [Failure].

class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException()
      : super(message: 'Unauthorized', statusCode: 401);
}

class NotFoundException extends ServerException {
  const NotFoundException({required super.message}) : super(statusCode: 404);
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({this.message = 'No internet connection'});

  @override
  String toString() => 'NetworkException: $message';
}
