class ValidationResult {
  const ValidationResult.valid() : isValid = true, messageKey = null;

  const ValidationResult.invalid(this.messageKey) : isValid = false;

  final bool isValid;
  final String? messageKey;

  @override
  String toString() =>
      'ValidationResult(isValid: $isValid, messageKey: $messageKey)';
}
