import '../../../core/validation/validation_result.dart';

abstract final class DobValidator {
  static const int minimumAge = 13;
  static final RegExp _digitsOnly = RegExp(r'^\d{1,2}/\d{1,2}/\d{4}$');

  static DateTime? parse(String raw) {
    if (!_digitsOnly.hasMatch(raw.trim())) {
      return null;
    }
    final parts = raw.trim().split('/');
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    return _buildDate(year, month, day);
  }

  static DateTime? _buildDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) {
      return null;
    }
    final isLeap = (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
    final maxDay = _daysInMonth(month, isLeap);
    if (day > maxDay) {
      return null;
    }
    return DateTime(year, month, day);
  }

  static int _daysInMonth(int month, bool isLeap) {
    return switch (month) {
      2 => isLeap ? 29 : 28,
      4 || 6 || 9 || 11 => 30,
      _ => 31,
    };
  }

  static int ageOn(DateTime birth, DateTime now) {
    var age = now.year - birth.year;
    final hadBirthday =
        (now.month > birth.month) ||
        (now.month == birth.month && now.day >= birth.day);
    if (!hadBirthday) {
      age--;
    }
    return age;
  }

  static ValidationResult validate(DateTime? date, {DateTime? now}) {
    if (date == null) {
      return const ValidationResult.invalid('dobInvalid');
    }
    final today = now ?? DateTime.now();
    final normalizedNow = DateTime(today.year, today.month, today.day);
    if (date.isAfter(normalizedNow)) {
      return const ValidationResult.invalid('dobFuture');
    }
    if (ageOn(date, normalizedNow) < minimumAge) {
      return const ValidationResult.invalid('dobTooYoung');
    }
    return const ValidationResult.valid();
  }
}
