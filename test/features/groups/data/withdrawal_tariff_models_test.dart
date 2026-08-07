import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/features/groups/data/models/withdrawal_tariff_models.dart';

void main() {
  group('WithdrawalTariffsResponse', () {
    test('parses the API contract and selects inclusive amount ranges', () {
      final response = WithdrawalTariffsResponse.fromJson({
        'service_id': '5',
        'tariffs': [
          {
            'display_fee': '0',
            'hesabu_online_fee': 0.0,
            'max_amount': 49.0,
            'min_amount': 1.0,
            'mpesa_fee': 0.0,
            'range': '1 - 49',
            'total_fee': 0.0,
          },
          {
            'display_fee': '6',
            'hesabu_online_fee': 1.0,
            'max_amount': 500.0,
            'min_amount': 50.0,
            'mpesa_fee': 5.0,
            'range': '50 - 500',
            'total_fee': 6.0,
          },
        ],
        'total_ranges': 2,
      });

      expect(response.serviceId, '5');
      expect(response.feeFor(1), 0);
      expect(response.feeFor(49), 0);
      expect(response.feeFor(50), 6);
      expect(response.feeFor(500), 6);
    });

    test('rejects amounts outside the configured tariff ranges', () {
      final response = WithdrawalTariffsResponse.fromJson({
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
        ],
        'total_ranges': 1,
      });

      expect(() => response.feeFor(50), throwsFormatException);
    });

    test('rejects malformed or incomplete tariff payloads', () {
      expect(
        () => WithdrawalTariffsResponse.fromJson({
          'service_id': '5',
          'tariffs': <Object?>[],
          'total_ranges': 1,
        }),
        throwsFormatException,
      );
    });
  });
}
