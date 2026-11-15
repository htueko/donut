import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/dio_interceptors.dart';
import '../../../core/network/reachability_service.dart';
import '../domain/catalog_repository.dart';
import 'catalog_repository_impl.dart';
import 'catalog_sync.dart';
import 'local/catalog_database.dart';
import 'local/catalog_seed.dart';

final catalogDatabaseProvider = Provider<CatalogDatabase>((ref) {
  throw UnimplementedError(
    'catalogDatabaseProvider must be overridden in main with an open database',
  );
});

final mockServerUrlProvider = Provider<String?>((ref) {
  const url = String.fromEnvironment('MOCK_SERVER_URL');
  return url.isEmpty ? null : url;
});

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(mockServerUrlProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl ?? '',
      connectTimeout: const Duration(seconds: 6),
    ),
  );
  dio.interceptors.addAll([RetryInterceptor(dio: dio), LoggingInterceptor()]);
  return dio;
});

final reachabilityServiceProvider = Provider<ReachabilityService>((ref) {
  return ReachabilityService(dio: Dio());
});

final catalogSyncProvider = Provider<CatalogSync?>((ref) {
  final url = ref.watch(mockServerUrlProvider);
  if (url == null) {
    return null;
  }
  return CatalogSync(
    ref.watch(dioProvider),
    ref.watch(catalogDatabaseProvider),
  );
});

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(
    ref.watch(catalogDatabaseProvider),
    sync: ref.watch(catalogSyncProvider),
  );
});

final catalogDataProvider = StreamProvider.autoDispose((ref) async* {
  final repository = ref.watch(catalogRepositoryProvider);
  await for (final data in repository.watchCatalog()) {
    yield data;
  }
});

final onlineStatusProvider = StreamProvider.autoDispose<bool>((ref) async* {
  final reachability = ref.watch(reachabilityServiceProvider);
  final connectivity = Connectivity();
  final initial = await connectivity.checkConnectivity();
  yield await _resolve(initial, reachability);
  await for (final statuses in connectivity.onConnectivityChanged) {
    yield await _resolve(statuses, reachability);
  }
});

Future<bool> _resolve(
  List<ConnectivityResult> statuses,
  ReachabilityService reachability,
) async {
  if (statuses.contains(ConnectivityResult.none)) {
    return false;
  }
  return reachability.isReachable();
}

Future<void> seedCatalog(CatalogDatabase db) => runSeed(db);
