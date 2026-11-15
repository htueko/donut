import 'package:donut/features/auth/domain/otp_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OtpValidator', () {
    test('accepts six-digit codes', () {
      expect(OtpValidator.isComplete('123456'), isTrue);
      expect(OtpValidator.isComplete('000000'), isTrue);
    });

    test('rejects partial or long codes', () {
      expect(OtpValidator.isComplete('12345'), isFalse);
      expect(OtpValidator.isComplete('1234567'), isFalse);
    });

    test('rejects non-numeric input', () {
      expect(OtpValidator.isComplete('12a456'), isFalse);
    });

    test('only the demo code matches', () {
      expect(OtpValidator.matches('123456'), isTrue);
      expect(OtpValidator.matches('111111'), isFalse);
    });
  });
}
