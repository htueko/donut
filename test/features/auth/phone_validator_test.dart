import 'package:donut/features/auth/domain/phone_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PhoneValidator.normalize', () {
    test('strips one leading zero and keeps valid digits', () {
      expect(PhoneValidator.normalize('09254135592'), '9254135592');
    });

    test('accepts a bare national number without leading zero', () {
      expect(PhoneValidator.normalize('9254135592'), '9254135592');
    });

    test('ignores spaces and dashes', () {
      expect(PhoneValidator.normalize('09 254 135 592'), '9254135592');
      expect(PhoneValidator.normalize('09-254-135-592'), '9254135592');
    });

    test('rejects numbers that do not start with 9 after stripping', () {
      expect(PhoneValidator.normalize('0812345678'), isNull);
    });

    test('rejects too few digits after 9', () {
      expect(PhoneValidator.normalize('9123'), isNull);
    });

    test('rejects too many digits', () {
      expect(PhoneValidator.normalize('925413559299'), isNull);
    });

    test('rejects letters and symbols', () {
      expect(PhoneValidator.normalize('09abc254135592'), isNull);
      expect(PhoneValidator.normalize('+959254135592'), isNull);
    });

    test('strips only one leading zero', () {
      expect(PhoneValidator.normalize('0092541355'), isNull);
      expect(PhoneValidator.normalize('092541355'), '92541355');
    });
  });

  group('PhoneValidator.validate', () {
    test('requires a value', () {
      expect(PhoneValidator.validate('').isValid, isFalse);
      expect(PhoneValidator.validate('   ').isValid, isFalse);
    });

    test('reports the invalid message key on bad input', () {
      expect(PhoneValidator.validate('123').messageKey, 'phoneInvalid');
    });

    test('accepts a normalized-valid number', () {
      expect(PhoneValidator.validate('09254135592').isValid, isTrue);
    });
  });
}
