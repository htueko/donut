import '../../../core/result.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'fake_auth_remote_data_source.dart';
import 'local/auth_dao.dart';
import 'session_store.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.dao,
    required this.session,
    FakeAuthRemoteDataSource? remote,
  }) : _remote = remote ?? FakeAuthRemoteDataSource();

  final AuthDao dao;
  final SessionStore session;
  final FakeAuthRemoteDataSource _remote;

  @override
  Future<Result<void>> verifyOtp(String otp) async {
    try {
      await _remote.verifyOtp(otp);
    } on AuthRequestException catch (error) {
      return FailureResult(ValidationFailure(error.code));
    }
    return const Success(null);
  }

  @override
  Future<Result<AppUser>> login({
    required String phoneE164,
    required String otp,
  }) async {
    try {
      await _remote.verifyOtp(otp);
    } on AuthRequestException catch (error) {
      return FailureResult(ValidationFailure(error.code));
    }
    final user = await dao.byPhone(phoneE164);
    if (user == null) {
      return const FailureResult(NotFoundFailure('phone_not_registered'));
    }
    await session.save(token: 'token-${user.id}', userId: user.id);
    return Success(user);
  }

  @override
  Future<Result<AppUser>> register({
    required String phoneE164,
    required String otp,
    required String firstName,
    String? lastName,
    required DateTime dateOfBirth,
  }) async {
    try {
      await _remote.verifyOtp(otp);
    } on AuthRequestException catch (error) {
      return FailureResult(ValidationFailure(error.code));
    }
    final existing = await dao.byPhone(phoneE164);
    final user = AppUser(
      id: existing?.id ?? 'u_${phoneE164.hashCode}',
      phoneE164: phoneE164,
      firstName: firstName,
      lastName: lastName,
      dateOfBirth: dateOfBirth,
    );
    await dao.upsert(user);
    await session.save(token: 'token-${user.id}', userId: user.id);
    return Success(user);
  }

  @override
  Future<Result<void>> logout() async {
    await session.clear();
    return const Success(null);
  }

  @override
  Future<AppUser?> currentUser() async {
    final userId = await session.readUserId();
    if (userId == null) {
      return null;
    }
    return dao.byId(userId);
  }

  @override
  Stream<AppUser?> watchCurrentUser() async* {
    final userId = await session.readUserId();
    if (userId == null) {
      yield null;
    } else {
      yield* dao.watchById(userId);
    }
  }
}
