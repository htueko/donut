import 'package:donut/features/auth/data/auth_providers.dart';
import 'package:donut/features/auth/data/auth_repository_impl.dart';
import 'package:donut/features/auth/data/fake_auth_remote_data_source.dart';
import 'package:donut/features/auth/data/local/auth_dao.dart';
import 'package:donut/features/auth/data/session_store.dart';
import 'package:donut/features/auth/domain/app_user.dart';
import 'package:donut/features/auth/domain/auth_repository.dart';
import 'package:donut/features/auth/presentation/auth_flow_provider.dart';
import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// In-memory stand-in for flutter_secure_storage.
class FakeSecureStorage implements SecureStorageGateway {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

/// An in-memory catalog plus an auth stack that talks to it, so widget and
/// integration tests drive the real repository without secure storage.
class FakeAuthEnv {
  FakeAuthEnv({Duration authDelay = const Duration(milliseconds: 20)}) {
    catalog = CatalogDatabase.inMemory();
    session = SessionStore(FakeSecureStorage());
    repository = AuthRepositoryImpl(
      dao: AuthDao(catalog),
      session: session,
      remote: FakeAuthRemoteDataSource(delay: authDelay),
    );
  }

  late final CatalogDatabase catalog;
  late final SessionStore session;
  late final AuthRepository repository;

  Future<void> dispose() async {
    await catalog.close();
    session.dispose();
  }

  List<Override> overrides({AppUser? user}) {
    return [
      catalogDatabaseProvider.overrideWithValue(catalog),
      authRepositoryProvider.overrideWithValue(repository),
      sessionStoreProvider.overrideWithValue(session),
      initialSessionUserProvider.overrideWithValue(user),
    ];
  }
}
