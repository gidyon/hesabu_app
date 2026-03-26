import 'package:dio/dio.dart';
import 'package:hesabu_app/core/network/auth_interceptor.dart';
import 'package:hesabu_app/core/network/auth_local_data_source.dart';

class ApiClient {
  late final Dio dio;

  ApiClient({AuthLocalDataSource? authLocalDataSource}) {
    dio = Dio(BaseOptions(
      baseUrl: 'https://gateway.hesabu.co.ke/v1', // Using a placeholder since staging base URL is not explicitly available in the collection body
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    if (authLocalDataSource != null) {
      dio.interceptors.add(AuthInterceptor(authLocalDataSource: authLocalDataSource));
    }
  }
}
