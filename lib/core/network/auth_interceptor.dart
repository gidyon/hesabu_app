import 'package:dio/dio.dart';
import 'package:hesabu_app/core/network/auth_local_data_source.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource authLocalDataSource;

  AuthInterceptor({required this.authLocalDataSource});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await authLocalDataSource.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = token;
    }

    super.onRequest(options, handler);
  }
}
