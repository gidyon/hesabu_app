import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DebugHttpLogInterceptor extends Interceptor {
  DebugHttpLogInterceptor({
    void Function(String message)? logSink,
    this.maxPayloadLength = 12000,
  }) : _logSink = logSink ?? debugPrint;

  static const String redactedValue = '<redacted>';
  static const Set<String> _sensitiveKeys = {
    'authorization',
    'accesstoken',
    'refreshtoken',
    'token',
    'password',
    'pin',
    'otp',
    'secret',
    'apikey',
    'clientsecret',
    'verificationcode',
    'resetcode',
  };

  final void Function(String message) _logSink;
  final int maxPayloadLength;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logSink('*** Request ***');
    _logSink('uri: ${options.uri}');
    _logSink('method: ${options.method}');
    _logSink('payload: ${_formatPayload(options.data)}');
    _logSink('');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logSink('*** Response ***');
    _logSink('uri: ${response.realUri}');
    _logSink('statusCode: ${response.statusCode}');
    _logSink('payload: ${_formatPayload(response.data)}');
    _logSink('');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logSink('*** DioException ***');
    _logSink('uri: ${err.requestOptions.uri}');
    _logSink('type: ${err.type}');
    _logSink('message: ${err.message ?? 'Request failed'}');
    if (err.response != null) {
      _logSink('statusCode: ${err.response?.statusCode}');
      _logSink('payload: ${_formatPayload(err.response?.data)}');
    }
    _logSink('');
    handler.next(err);
  }

  String _formatPayload(Object? payload) {
    final redacted = redactPayload(payload);
    String formatted;
    try {
      formatted = redacted is String ? redacted : jsonEncode(redacted);
    } on JsonUnsupportedObjectError {
      formatted = redacted.toString();
    }
    if (formatted.length <= maxPayloadLength) return formatted;
    return '${formatted.substring(0, maxPayloadLength)}...<truncated>';
  }

  @visibleForTesting
  static Object? redactPayload(Object? value, {String? key}) {
    if (key != null && _isSensitiveKey(key)) {
      return redactedValue;
    }
    if (value is Map) {
      return value.map(
        (mapKey, mapValue) => MapEntry(
          mapKey.toString(),
          redactPayload(mapValue, key: mapKey.toString()),
        ),
      );
    }
    if (value is Iterable) {
      return value.map((item) => redactPayload(item)).toList(growable: false);
    }
    if (value is FormData) {
      return {
        'fields': {
          for (final field in value.fields)
            field.key: redactPayload(field.value, key: field.key),
        },
        'files': [for (final file in value.files) file.key],
      };
    }
    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalized = key.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return _sensitiveKeys.contains(normalized) ||
        normalized.contains('password') ||
        normalized.endsWith('token') ||
        normalized.contains('secret');
  }
}
