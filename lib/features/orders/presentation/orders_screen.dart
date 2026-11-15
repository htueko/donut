import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.orders ?? 'Orders'),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)?.emptyGeneric ?? 'Nothing yet',
        ),
      ),
    );
  }
}
