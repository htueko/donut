import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _tabs = <String>['/home', '/rewards', '/cart', '/settings'];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final location = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indexOf(location),
        onDestinationSelected: (index) => context.go(_tabs[index]),
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.16),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n?.homeTab ?? 'Home',
          ),
          NavigationDestination(
            icon: const _RewardsTabIcon(selected: false),
            selectedIcon: const _RewardsTabIcon(selected: true),
            label: l10n?.rewardsTitle ?? 'Rewards',
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: l10n?.cartTab ?? 'Cart',
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n?.settings ?? 'Settings',
          ),
        ],
      ),
    );
  }

  static int _indexOf(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i])) {
        return i;
      }
    }
    return 0;
  }
}

class _RewardsTabIcon extends StatelessWidget {
  const _RewardsTabIcon({required this.selected});

  static const _badgeCount = 3;

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Badge(
      label: const Text('$_badgeCount'),
      child: Icon(
        selected ? Icons.card_giftcard : Icons.card_giftcard_outlined,
      ),
    );
  }
}
