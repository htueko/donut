import '../../../core/result.dart';
import 'app_user.dart';

abstract interface class AuthRepository {
  Future<Result<AppUser>> login({
    required String phoneE164,
    required String otp,
  });

  Future<Result<AppUser>> register({
    required String phoneE164,
    required String otp,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  });

  Future<Result<void>> logout();

  Future<AppUser?> currentUser();

  Stream<AppUser?> watchCurrentUser();
}
