import 'package:flutter_test/flutter_test.dart';
import 'package:hesabu_app/core/utils/phone_utils.dart';

void main() {
  group('PhoneUtils', () {
    test('normalizes common Kenyan contact formats', () {
      expect(PhoneUtils.formatMsisdn('0712 345 678'), '254712345678');
      expect(PhoneUtils.formatMsisdn('+254 712-345-678'), '254712345678');
      expect(PhoneUtils.formatMsisdn('(0112) 345 678'), '254112345678');
    });

    test('validates normalized phone numbers', () {
      expect(PhoneUtils.isValidMsisdn('+254 712 345 678'), isTrue);
      expect(PhoneUtils.isValidMsisdn('0712-345-678'), isTrue);
      expect(PhoneUtils.isValidMsisdn('12345'), isFalse);
    });
  });
}
