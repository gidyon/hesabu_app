import 'package:dio/dio.dart';

void configureInsecureTlsAdapter(
  Dio dio, {
  required String allowedHost,
  required int allowedPort,
}) {}

bool isAllowedInsecureTlsEndpoint({
  required String requestHost,
  required int requestPort,
  required String allowedHost,
  required int allowedPort,
}) =>
    requestHost.toLowerCase() == allowedHost.toLowerCase() &&
    requestPort == allowedPort;
