import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hesabu_app/core/network/auth_interceptor.dart';
import 'package:hesabu_app/core/network/auth_local_data_source.dart';
import 'package:hesabu_app/core/network/debug_http_log_interceptor.dart';
import 'package:hesabu_app/core/network/insecure_tls_adapter.dart';

class ApiClient {
  static const String defaultBaseUrl = 'https://stagingapp.hesabuonline.com';
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: defaultBaseUrl,
  );
  static const bool insecureTlsEnabled = bool.fromEnvironment(
    'ALLOW_INSECURE_TLS',
    defaultValue: false,
  );

  late final Dio dio;

  ApiClient({
    AuthLocalDataSource? authLocalDataSource,
    bool? allowInsecureTls,
  }) {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final shouldAllowInsecureTls = allowInsecureTls ?? insecureTlsEnabled;
    if (shouldAllowInsecureTls) {
      if (kIsWeb) {
        debugPrint(
          'ALLOW_INSECURE_TLS is not supported on web. Fix the server certificate.',
        );
      } else {
        final endpoint = Uri.parse(baseUrl);
        configureInsecureTlsAdapter(
          dio,
          allowedHost: endpoint.host,
          allowedPort: endpoint.hasPort ? endpoint.port : 443,
        );
        debugPrint(
          'WARNING: TLS certificate verification is bypassed only for '
          '${endpoint.host}:${endpoint.hasPort ? endpoint.port : 443}.',
        );
      }
    }

    if (kDebugMode) {
      dio.interceptors.add(DebugHttpLogInterceptor());
    }

    if (authLocalDataSource != null) {
      dio.interceptors.add(
        AuthInterceptor(authLocalDataSource: authLocalDataSource),
      );
    }
  }
}
