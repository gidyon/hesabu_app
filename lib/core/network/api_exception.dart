class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException({required this.message, this.statusCode});

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException: $statusCode - $message';
    }
    return 'ApiException: $message';
  }
}

class NetworkException extends ApiException {
  NetworkException()
    : super(message: 'No internet connection or network error.');
}

class UnauthorizedException extends ApiException {
  UnauthorizedException()
    : super(message: 'Unauthorized access.', statusCode: 401);
}

class ServerException extends ApiException {
  ServerException({String? message})
    : super(message: message ?? 'Internal server error.', statusCode: 500);
}
