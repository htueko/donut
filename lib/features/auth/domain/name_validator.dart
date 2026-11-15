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
          ? const ValidationResult.invalid('nameRequired')
          : const ValidationResult.valid();
    }
    if (trimmed.length > maxLength) {
      return const ValidationResult.invalid('nameTooLong');
    }
    if (_hasDigit.hasMatch(trimmed) || !_lettersOrSpaces.hasMatch(trimmed)) {
      return const ValidationResult.invalid('nameInvalidChars');
    }
    return const ValidationResult.valid();
  }
}
