import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.cartTab ?? 'Cart'),
      ),
      body: Center(
        child: Text(
          AppLocalizations.of(context)?.emptyGeneric ?? 'Nothing yet',
        ),
      ),
    );
  }
}
