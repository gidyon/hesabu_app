import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/network/api_client.dart';
import 'package:hesabu_app/features/groups/data/groups_remote_data_source.dart';

void main() {
  test(
    'requests tariffs using POST with the API empty-body contract',
    () async {
      final adapter = _TariffsAdapter();
      final apiClient = ApiClient()..dio.httpClientAdapter = adapter;
      final remoteDataSource = GroupsRemoteDataSource(apiClient: apiClient);

      final fee = await remoteDataSource.getWithdrawalFee(amount: 50);

      expect(fee, 6);
      expect(adapter.request?.method, 'POST');
      expect(adapter.request?.path, '/tariffs');
      expect(adapter.requestData, '');
    },
  );
}

class _TariffsAdapter implements HttpClientAdapter {
  RequestOptions? request;
  String? requestData;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    request = options;
    final requestBytes = await requestStream?.fold<List<int>>(
      <int>[],
      (bytes, chunk) => bytes..addAll(chunk),
    );
    requestData = requestBytes == null ? null : utf8.decode(requestBytes);

    return ResponseBody.fromString(
      jsonEncode({
        'service_id': '5',
        'tariffs': [
          {
            'display_fee': '0',
            'hesabu_online_fee': 0,
            'max_amount': 49,
            'min_amount': 1,
            'mpesa_fee': 0,
            'range': '1 - 49',
            'total_fee': 0,
          },
          {
            'display_fee': '6',
            'hesabu_online_fee': 1,
            'max_amount': 500,
            'min_amount': 50,
            'mpesa_fee': 5,
            'range': '50 - 500',
            'total_fee': 6,
          },
        ],
        'total_ranges': 2,
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
