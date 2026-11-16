import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/data/catalog_providers.dart';

class CatalogRefreshListener extends ConsumerStatefulWidget {
  const CatalogRefreshListener({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<CatalogRefreshListener> createState() =>
      _CatalogRefreshListenerState();
}

class _CatalogRefreshListenerState
    extends ConsumerState<CatalogRefreshListener> {
  bool _wasOffline = false;

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(onlineStatusProvider).valueOrNull ?? true;
    if (_wasOffline && online) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.invalidate(catalogDataProvider);
      });
    }
    _wasOffline = !online;
    return widget.child;
  }
}
