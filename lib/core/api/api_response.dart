class ApiResponse<T> {
  final T? data;
  final String? errorMessage;
  final bool hasError;

  ApiResponse({this.data, this.errorMessage, this.hasError = false});

  factory ApiResponse.success(T data) {
    return ApiResponse(data: data, hasError: false);
  }

  factory ApiResponse.error(String message) {
    return ApiResponse(errorMessage: message, hasError: true);
  }
}
