import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void configureInsecureTlsAdapter(
  Dio dio, {
  required String allowedHost,
  required int allowedPort,
}) {
  dio.httpClientAdapter = IOHttpClientAdapter(
    createHttpClient: () {
      final client = HttpClient();
      client.badCertificateCallback = (certificate, host, port) =>
          isAllowedInsecureTlsEndpoint(
            requestHost: host,
            requestPort: port,
            allowedHost: allowedHost,
            allowedPort: allowedPort,
          );
      return client;
    },
  );
}

bool isAllowedInsecureTlsEndpoint({
  required String requestHost,
  required int requestPort,
  required String allowedHost,
  required int allowedPort,
}) =>
    requestHost.toLowerCase() == allowedHost.toLowerCase() &&
    requestPort == allowedPort;
