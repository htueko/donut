import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.notifications ?? 'Notifications',
        ),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)?.emptyGeneric ?? 'Nothing yet',
        ),
      ),
    );
  }
}
