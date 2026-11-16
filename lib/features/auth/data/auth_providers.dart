import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/data/catalog_providers.dart';
import '../domain/app_user.dart';
import '../domain/auth_repository.dart';
import 'auth_repository_impl.dart';
import 'local/auth_dao.dart';
import 'session_store.dart';

final authDaoProvider = Provider<AuthDao>((ref) {
  return AuthDao(ref.watch(catalogDatabaseProvider));
});

final sessionStoreProvider = Provider<SessionStore>((ref) {
  return SessionStore();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    dao: ref.watch(authDaoProvider),
    session: ref.watch(sessionStoreProvider),
  );
});

final sessionUserProvider = StreamProvider.autoDispose<AppUser?>((ref) async* {
  final repository = ref.watch(authRepositoryProvider);
  yield* repository.watchCurrentUser();
});
