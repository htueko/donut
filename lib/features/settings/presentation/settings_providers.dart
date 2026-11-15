import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/session_store.dart';

final localeProvider = StateProvider<Locale?>((ref) => null);

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

class SettingsStore {
  SettingsStore([SecureStorageGateway? gateway])
    : _storage = gateway ?? const FlutterSecureStorageGateway();

  final SecureStorageGateway _storage;

  static const _localeKey = 'settings_locale';
  static const _themeModeKey = 'settings_theme_mode';

  Future<void> saveLocale(Locale? locale) async {
    if (locale == null) {
      await _storage.delete(_localeKey);
    } else {
      await _storage.write(_localeKey, locale.languageCode);
    }
  }

  Future<Locale?> readLocale() async {
    final value = await _storage.read(_localeKey);
    if (value == null) {
      return null;
    }
    return Locale(value);
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(_themeModeKey, mode.name);
  }

  Future<ThemeMode> readThemeMode() async {
    final value = await _storage.read(_themeModeKey);
    return ThemeMode.values.byName(value ?? 'system');
  }
}

final settingsStorageProvider = Provider<SecureStorageGateway>(
  (ref) => const FlutterSecureStorageGateway(),
);

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  return SettingsStore(ref.watch(settingsStorageProvider));
});
