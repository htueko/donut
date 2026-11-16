import 'package:donut/features/auth/domain/dob_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 15);

  group('DobValidator.parse', () {
    test('parses a valid date string', () {
      expect(DobValidator.parse('14/03/2000'), DateTime(2000, 3, 14));
    });

    test('rejects malformed strings', () {
      expect(DobValidator.parse('2000-03-14'), isNull);
      expect(DobValidator.parse('45/13/2000'), isNull);
      expect(DobValidator.parse(''), isNull);
    });

    test('rejects 31 April', () {
      expect(DobValidator.parse('31/04/2001'), isNull);
    });

    test('rejects 29 February on non-leap years', () {
      expect(DobValidator.parse('29/02/2001'), isNull);
    });

    test('accepts 29 February on leap years', () {
      expect(DobValidator.parse('29/02/2000'), DateTime(2000, 2, 29));
      expect(DobValidator.parse('29/02/2024'), DateTime(2024, 2, 29));
    });
  });

  group('DobValidator.validate', () {
    test('rejects missing dates', () {
      expect(DobValidator.validate(null).isValid, isFalse);
      expect(DobValidator.validate(null).messageKey, 'dobInvalid');
    });

    test('rejects future dates', () {
      expect(
        DobValidator.validate(DateTime(2030, 1, 1)).messageKey,
        'dobFuture',
      );
    });

    test('rejects users younger than the minimum age', () {
      final birth = DateTime(
        now.year - DobValidator.minimumAge,
        now.month,
        now.day + 1,
      );
      expect(DobValidator.validate(birth, now: now).messageKey, 'dobTooYoung');
    });

    test('accepts users exactly at the minimum age', () {
      final birth = DateTime(
        now.year - DobValidator.minimumAge,
        now.month,
        now.day,
      );
      expect(DobValidator.validate(birth, now: now).isValid, isTrue);
    });

    test('age calculation accounts for birthdays later in the year', () {
      final birth = DateTime(2010, 12, 31);
      expect(DobValidator.ageOn(birth, DateTime(2026, 1, 1)), 15);
      expect(DobValidator.ageOn(birth, DateTime(2025, 12, 30)), 14);
    });
  });
}
