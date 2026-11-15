import 'package:flutter/material.dart';

import '../../../../app/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          '${AppLocalizations.of(context)?.appTitle ?? ''} Home (C13)',
        ),
      ),
      bottomNavigationBar: const SizedBox(height: AppSpacing.bottomNavHeight),
    );
  }
}
