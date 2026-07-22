class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode = 200,
  });

  factory ApiResponse.success(T data) => ApiResponse(success: true, data: data);
  factory ApiResponse.error(String message, {int statusCode = 400}) =>
      ApiResponse(success: false, message: message, statusCode: statusCode);
}
