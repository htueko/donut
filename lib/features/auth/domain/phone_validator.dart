import '../../../core/validation/validation_result.dart';

abstract final class PhoneValidator {
  static final RegExp _allowedChars = RegExp(r'^[0-9 \-]+$');
  static final RegExp _e164 = RegExp(r'^9[0-9]{7,9}$');

  static String? normalize(String raw) {
    if (raw.isEmpty || !_allowedChars.hasMatch(raw)) {
      return null;
    }
    final compact = raw.replaceAll(RegExp(r'[ \-]'), '');
    final digits = compact.startsWith('0') ? compact.substring(1) : compact;
    return _e164.hasMatch(digits) ? digits : null;
  }

  static ValidationResult validate(String raw) {
    if (raw.trim().isEmpty) {
      return ValidationResult.invalid('phoneRequired');
    }
    if (normalize(raw) == null) {
      return ValidationResult.invalid('phoneInvalid');
    }
    return const ValidationResult.valid();
  }
}
