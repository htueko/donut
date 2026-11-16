import 'package:donut/core/result.dart';
import 'package:donut/features/auth/data/auth_repository_impl.dart';
import 'package:donut/features/auth/data/fake_auth_remote_data_source.dart';
import 'package:donut/features/auth/data/local/auth_dao.dart';
import 'package:donut/features/auth/data/session_store.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart';
import 'package:flutter_test/flutter_test.dart';

class InMemorySecureStorage implements SecureStorageGateway {
  final Map<String, String> _store = {};

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }
}

void main() {
  late CatalogDatabase db;
  late AuthRepositoryImpl repository;
  late SessionStore session;
  late InMemorySecureStorage storage;

  setUp(() {
    db = CatalogDatabase.inMemory();
    storage = InMemorySecureStorage();
    session = SessionStore(storage);
    repository = AuthRepositoryImpl(
      dao: AuthDao(db),
      session: session,
      remote: FakeAuthRemoteDataSource(delay: Duration.zero),
    );
  });

  tearDown(() async {
    session.dispose();
    await db.close();
  });

  test('login fails with phone_not_registered for unknown numbers', () async {
    final result = await repository.login(
      phoneE164: '9254135592',
      otp: '123456',
    );
    expect(result.isFailure, isTrue);
    final failure = result.failureOrNull;
    expect(failure, isA<NotFoundFailure>());
    expect((failure as NotFoundFailure).message, 'phone_not_registered');
  });

  test('login fails with otp_invalid for a wrong code', () async {
    final result = await repository.login(
      phoneE164: '9254135592',
      otp: '111111',
    );
    expect(result.failureOrNull, isA<ValidationFailure>());
  });

  test('register persists the user and starts a session', () async {
    final result = await repository.register(
      phoneE164: '9254135592',
      otp: '123456',
      firstName: 'Su Su',
      lastName: 'Hlaing',
      dateOfBirth: DateTime(1995, 6, 15),
    );

    expect(result.isSuccess, isTrue);
    final user = result.valueOrNull;
    expect(user?.phoneE164, '9254135592');

    final stored = await repository.currentUser();
    expect(stored, isNotNull);
    expect(stored?.firstName, 'Su Su');
    expect(stored?.lastName, 'Hlaing');
  });

  test('login succeeds for a registered number with the demo code', () async {
    await repository.register(
      phoneE164: '9254135592',
      otp: '123456',
      firstName: 'Su Su',
      dateOfBirth: DateTime(1995, 6, 15),
    );

    final result = await repository.login(
      phoneE164: '9254135592',
      otp: '123456',
    );
    expect(result.isSuccess, isTrue);
  });

  test('logout clears the session so currentUser becomes null', () async {
    await repository.register(
      phoneE164: '9254135592',
      otp: '123456',
      firstName: 'Su Su',
      dateOfBirth: DateTime(1995, 6, 15),
    );
    expect(await repository.currentUser(), isNotNull);

    await repository.logout();
    expect(await repository.currentUser(), isNull);
  });

  test('watchCurrentUser emits null when logged out', () async {
    final first = await repository.watchCurrentUser().first;
    expect(first, isNull);
  });
}
