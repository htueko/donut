import 'package:donut/features/auth/domain/name_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NameValidator', () {
    test('requires first names', () {
      expect(NameValidator.validate('', required: true).isValid, isFalse);
      expect(
        NameValidator.validate('   ', required: true).messageKey,
        'nameRequired',
      );
    });

    test('allows an empty last name when optional', () {
      expect(NameValidator.validate('', required: false).isValid, isTrue);
    });

    test('accepts plain and spaced names', () {
      expect(NameValidator.validate('Su Su', required: true).isValid, isTrue);
      expect(NameValidator.validate('Aung', required: true).isValid, isTrue);
    });

    test('accepts Myanmar script letters and spaces', () {
      expect(NameValidator.validate('à帝的ေႃသူ', required: true).isValid, isTrue);
    });

    test('rejects digits anywhere', () {
      expect(NameValidator.validate('Aung 2', required: true).isValid, isFalse);
      expect(
        NameValidator.validate('User123', required: true).messageKey,
        'nameInvalidChars',
      );
    });

    test('rejects punctuation and symbols', () {
      expect(NameValidator.validate('Aung-', required: true).isValid, isFalse);
      expect(NameValidator.validate('a.b', required: true).isValid, isFalse);
    });

    test('enforces the 50 character limit after trimming', () {
      final long = 'a' * 51;
      expect(
        NameValidator.validate(long, required: true).messageKey,
        'nameTooLong',
      );
      expect(NameValidator.validate('a' * 50, required: true).isValid, isTrue);
    });
  });
}
