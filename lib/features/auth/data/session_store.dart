import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageGateway {
  Future<String?> read(String key);

  Future<void> write(String key, String? value);

  Future<void> delete(String key);
}

class FlutterSecureStorageGateway implements SecureStorageGateway {
  const FlutterSecureStorageGateway([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String? value) {
    return _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class SessionStore {
  SessionStore([SecureStorageGateway? gateway])
    : _storage = gateway ?? const FlutterSecureStorageGateway();

  static const String _tokenKey = 'session_token';
  static const String _userIdKey = 'session_user_id';

  final SecureStorageGateway _storage;
  final StreamController<String?> _changes =
      StreamController<String?>.broadcast();

  Stream<String?> get changes => _changes.stream;

  Future<String?> readToken() => _storage.read(_tokenKey);

  Future<String?> readUserId() => _storage.read(_userIdKey);

  Future<void> save({required String token, required String userId}) async {
    await _storage.write(_tokenKey, token);
    await _storage.write(_userIdKey, userId);
    _changes.add(token);
  }

  Future<void> clear() async {
    await _storage.delete(_tokenKey);
    await _storage.delete(_userIdKey);
    _changes.add(null);
  }

  void dispose() {
    _changes.close();
  }
}
