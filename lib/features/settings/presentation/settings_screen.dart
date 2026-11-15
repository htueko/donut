import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_flow_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(sessionControllerProvider);
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
            leading: const Icon(Icons.logout),
            title: Text(l10n?.logOut ?? 'Log out'),
            onTap: () => _logout(context, ref),
          ),
        ],
      ),
    );
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
