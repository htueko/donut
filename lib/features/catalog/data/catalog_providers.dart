import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog_repository.dart';
import 'local/catalog_database.dart';
import 'catalog_repository_impl.dart';
import 'local/catalog_seed.dart';

final catalogDatabaseProvider = Provider<CatalogDatabase>((ref) {
  throw UnimplementedError(
    'catalogDatabaseProvider must be overridden in main with an open database',
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(ref.watch(catalogDatabaseProvider));
});

final catalogDataProvider = StreamProvider.autoDispose((ref) async* {
  final repository = ref.watch(catalogRepositoryProvider);
  await for (final data in repository.watchCatalog()) {
    yield data;
  }
});

Future<void> seedCatalog(CatalogDatabase db) => runSeed(db);
