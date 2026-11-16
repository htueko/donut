import '../domain/otp_validator.dart';

class AuthRequestException implements Exception {
  const AuthRequestException(this.code);
  final String code;
}

class FakeAuthRemoteDataSource {
  FakeAuthRemoteDataSource({Duration? delay})
    : _delay = delay ?? const Duration(seconds: 1);

  final Duration _delay;

  Future<void> verifyOtp(String otp) async {
    await Future<void>.delayed(_delay);
    if (!OtpValidator.matches(otp)) {
      throw const AuthRequestException('otp_invalid');
    }
  }
}
