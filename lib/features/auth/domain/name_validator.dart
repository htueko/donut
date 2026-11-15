import '../../../core/validation/validation_result.dart';

abstract final class NameValidator {
  static const int maxLength = 50;
  static final RegExp _lettersOrSpaces = RegExp(
    r'^[\p{L}\p{M} ]+$',
    unicode: true,
  );
  static final RegExp _hasDigit = RegExp(r'\d', unicode: true);

  static ValidationResult validate(String raw, {required bool required}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return required
          ? ValidationResult.invalid('nameRequired')
          : ValidationResult.valid();
    }
    if (trimmed.length > maxLength) {
      return ValidationResult.invalid('nameTooLong');
    }
    if (_hasDigit.hasMatch(trimmed) || !_lettersOrSpaces.hasMatch(trimmed)) {
      return ValidationResult.invalid('nameInvalidChars');
    }
    return ValidationResult.valid();
  }
}
