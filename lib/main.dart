import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'features/auth/data/local/auth_dao.dart';
import 'features/auth/data/session_store.dart';
import 'features/auth/domain/app_user.dart';
import 'features/auth/presentation/auth_flow_provider.dart';
import 'features/catalog/data/catalog_providers.dart';
import 'features/catalog/data/local/catalog_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await CatalogDatabase.open();
  await seedCatalog(db);

  final sessionStore = SessionStore();
  final token = await sessionStore.readToken();
  final userId = await sessionStore.readUserId();
  final initialUser = (token != null && userId != null)
      ? await AuthDao(db).byId(userId)
      : null;

  runApp(
    ProviderScope(
      overrides: [
        catalogDatabaseProvider.overrideWithValue(db),
        initialSessionUserProvider.overrideWithValue(initialUser),
      ],
      child: const DonutApp(),
    ),
  );
}

typedef BootstrapUser = AppUser?;
