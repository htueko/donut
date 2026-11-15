import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  SessionStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _tokenKey = 'session_token';
  static const String _userIdKey = 'session_user_id';

  final FlutterSecureStorage _storage;
  final StreamController<String?> _changes =
      StreamController<String?>.broadcast();

  Stream<String?> get changes => _changes.stream;

  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  Future<String?> readUserId() {
    return _storage.read(key: _userIdKey);
  }

  Future<void> save({required String token, required String userId}) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userIdKey, value: userId);
    _changes.add(token);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userIdKey);
    _changes.add(null);
  }

  Future<bool> get isLoggedIn async => await readToken() != null;

  void dispose() {
    _changes.close();
  }
}
