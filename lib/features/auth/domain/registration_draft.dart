class RegistrationDraft {
  const RegistrationDraft({
    this.phoneE164,
    this.otp,
    this.firstName,
    this.lastName,
    this.dateOfBirth,
  });

  final String? phoneE164;
  final String? otp;
  final String? firstName;
  final String? lastName;
  final DateTime? dateOfBirth;

  RegistrationDraft copyWith({
    String? phoneE164,
    String? otp,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
  }) {
    return RegistrationDraft(
      phoneE164: phoneE164 ?? this.phoneE164,
      otp: otp ?? this.otp,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    );
  }

  @override
  String toString() =>
      'RegistrationDraft(phoneE164: $phoneE164, '
      'firstName: $firstName, lastName: $lastName, '
      'dateOfBirth: $dateOfBirth)';
}
