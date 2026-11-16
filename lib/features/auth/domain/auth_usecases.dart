import '../../../core/result.dart';
import 'app_user.dart';
import 'auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String otp) => _repository.verifyOtp(otp);
}

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call({
    required String phoneE164,
    required String otp,
  }) {
    return _repository.login(phoneE164: phoneE164, otp: otp);
  }
}

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AppUser>> call({
    required String phoneE164,
    required String otp,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  }) {
    return _repository.register(
      phoneE164: phoneE164,
      otp: otp,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
    );
  }
}

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() => _repository.logout();
}

class ObserveSessionUseCase {
  const ObserveSessionUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AppUser?> call() => _repository.watchCurrentUser();

  Future<AppUser?> current() => _repository.currentUser();
}
