import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/network/debug_http_log_interceptor.dart';

void main() {
  test('redacts credentials while preserving useful request fields', () {
    final payload =
        DebugHttpLogInterceptor.redactPayload({
              'msisdn': '254700000000',
              'password': 'do-not-log',
              'password_confirmation': 'do-not-log-either',
              'nested': {'access_token': 'secret-token', 'amount': 100},
            })
            as Map<String, dynamic>;

    expect(payload['msisdn'], '254700000000');
    expect(payload['password'], DebugHttpLogInterceptor.redactedValue);
    expect(
      payload['password_confirmation'],
      DebugHttpLogInterceptor.redactedValue,
    );
    expect(
      (payload['nested'] as Map<String, dynamic>)['access_token'],
      DebugHttpLogInterceptor.redactedValue,
    );
    expect((payload['nested'] as Map<String, dynamic>)['amount'], 100);
  });

  test('logs redacted request and response payloads', () async {
    final logs = <String>[];
    final dio = Dio()
      ..httpClientAdapter = _JsonAdapter()
      ..interceptors.add(DebugHttpLogInterceptor(logSink: logs.add));

    await dio.post<void>(
      'https://example.test/login',
      data: {'msisdn': '254700000000', 'password': 'request-secret'},
    );

    final output = logs.join('\n');
    expect(output, contains('*** Request ***'));
    expect(output, contains('"msisdn":"254700000000"'));
    expect(output, contains('*** Response ***'));
    expect(output, contains('"message":"Authenticated"'));
    expect(output, contains('"password":"<redacted>"'));
    expect(output, contains('"access_token":"<redacted>"'));
    expect(output, isNot(contains('request-secret')));
    expect(output, isNot(contains('response-secret')));
  });
}

class _JsonAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    '{"access_token":"response-secret","message":"Authenticated"}',
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}
