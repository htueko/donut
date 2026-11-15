import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/result.dart';
import '../data/auth_providers.dart';
import '../domain/app_user.dart';
import '../domain/auth_usecases.dart';
import '../domain/registration_draft.dart';

final registrationDraftProvider = StateProvider<RegistrationDraft>(
  (ref) => const RegistrationDraft(),
);

final initialSessionUserProvider = Provider<AppUser?>((ref) => null);

class SessionController extends StateNotifier<AppUser?> {
  SessionController(super.initial);

  set currentAppUser(AppUser? user) => state = user;
}

final sessionControllerProvider =
    StateNotifierProvider<SessionController, AppUser?>((ref) {
      return SessionController(ref.watch(initialSessionUserProvider));
    });

class AuthFlow {
  const AuthFlow(this._ref);

  final Ref _ref;

  LoginUseCase get _login => LoginUseCase(_ref.watch(authRepositoryProvider));

  RegisterUseCase get _register =>
      RegisterUseCase(_ref.watch(authRepositoryProvider));

  LogoutUseCase get _logout =>
      LogoutUseCase(_ref.watch(authRepositoryProvider));

  Future<Result<AppUser>> login({
    required String phoneE164,
    required String otp,
  }) async {
    final result = await _login(phoneE164: phoneE164, otp: otp);
    result.when(
      onSuccess: (user) =>
          _ref.read(sessionControllerProvider.notifier).currentAppUser = user,
      onFailure: (_) {},
    );
    return result;
  }

  Future<Result<AppUser>> register(RegistrationDraft draft, String otp) async {
    final result = await _register(
      phoneE164: draft.phoneE164!,
      otp: otp,
      firstName: draft.firstName!,
      lastName: draft.lastName,
      dateOfBirth: draft.dateOfBirth!,
    );
    result.when(
      onSuccess: (user) =>
          _ref.read(sessionControllerProvider.notifier).currentAppUser = user,
      onFailure: (_) {},
    );
    return result;
  }

  Future<Result<void>> logout() async {
    final result = await _logout();
    _ref.read(sessionControllerProvider.notifier).currentAppUser = null;
    return result;
  }
}

final authFlowProvider = Provider<AuthFlow>((ref) => AuthFlow(ref));
