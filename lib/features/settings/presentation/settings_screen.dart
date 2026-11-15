import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_flow_provider.dart';
import 'settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n?.settings ?? 'Settings')),
      body: ListView(
        children: [
          if (user != null)
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user.fullName),
              subtitle: Text(user.phoneE164),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n?.language ?? 'Language'),
            subtitle: Text(
              locale?.languageCode == 'my'
                  ? (l10n?.myanmar ?? 'Myanmar')
                  : (l10n?.english ?? 'English'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showLanguageDialog(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n?.theme ?? 'Theme'),
            subtitle: Text(
              themeMode == ThemeMode.dark
                  ? (l10n?.darkTheme ?? 'Dark')
                  : themeMode == ThemeMode.light
                  ? (l10n?.lightTheme ?? 'Light')
                  : (l10n?.systemTheme ?? 'System'),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showThemeDialog(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n?.logOut ?? 'Log out'),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.read(localeProvider);
    final selected = await showDialog<Locale?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n?.language ?? 'Language'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(null),
            child: Row(
              children: [
                if (currentLocale == null)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(l10n?.english ?? 'English'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(const Locale('my')),
            child: Row(
              children: [
                if (currentLocale?.languageCode == 'my')
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(l10n?.myanmar ?? 'Myanmar'),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null || currentLocale != null) {
      ref.read(localeProvider.notifier).state = selected;
      await ref.read(settingsStoreProvider).saveLocale(selected);
    }
  }

  Future<void> _showThemeDialog(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final currentTheme = ref.read(themeModeProvider);
    final selected = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n?.theme ?? 'Theme'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(ThemeMode.light),
            child: Row(
              children: [
                if (currentTheme == ThemeMode.light)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(l10n?.lightTheme ?? 'Light'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(ThemeMode.dark),
            child: Row(
              children: [
                if (currentTheme == ThemeMode.dark)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(l10n?.darkTheme ?? 'Dark'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(ThemeMode.system),
            child: Row(
              children: [
                if (currentTheme == ThemeMode.system)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 12),
                Text(l10n?.systemTheme ?? 'System'),
              ],
            ),
          ),
        ],
      ),
    );
    if (selected != null) {
      ref.read(themeModeProvider.notifier).state = selected;
      await ref.read(settingsStoreProvider).saveThemeMode(selected);
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final message =
        AppLocalizations.of(context)?.loggedOutMessage ??
        'You have been logged out';
    await ref.read(authFlowProvider).logout();
    messenger.showSnackBar(SnackBar(content: Text(message)));
    router.go('/onboarding');
  }
}
