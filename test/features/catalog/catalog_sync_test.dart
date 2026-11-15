import 'package:dio/dio.dart';
import 'package:donut/core/result.dart';
import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/catalog_sync.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/mock_dio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogDatabase db;

  setUp(() async {
    db = CatalogDatabase.inMemory();
    await seedCatalog(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('refresh parses the data envelope and replaces local rows', () async {
    final dio = MockDio(
      responses: {
        '/v1/products': {'data': _envelopeList(_products)},
        '/v1/banners': {'data': _envelopeList(_banners)},
        '/v1/shops': {'data': _envelopeList(_shops)},
        '/v1/challenges': {'data': _envelopeList(_challenges)},
        '/v1/member': {'data': _member},
      },
    );
    final sync = CatalogSync(dio, db);

    final result = await sync.refresh();

    expect(result, isA<Success<void>>());
    final data = await db.catalogDao.loadCatalog();
    expect(data.products, hasLength(1));
    expect(data.products.single.id, 'p_coconut');
    expect(data.products.single.name, 'Coconut Donut');
    expect(data.banners, hasLength(1));
    expect(data.shops, hasLength(1));
    expect(data.challenges, hasLength(1));
    expect(data.member?.points, 680000);
  });

  test('refresh returns a network failure when the server is down', () async {
    final dio = MockDio(
      responses: const {},
      failure: DioException.connectionError(
        requestOptions: RequestOptions(path: '/v1/products'),
        reason: 'offline',
      ),
    );
    final sync = CatalogSync(dio, db);

    final result = await sync.refresh();

    expect(result, isA<FailureResult<void>>());
    expect(result.failureOrNull, isA<NetworkFailure>());
  });

  test('refresh keeps local data intact when the payload is malformed', () async {
    final before = await db.catalogDao.loadCatalog();
    final dio = MockDio(
      responses: {
        '/v1/products': {'data': 'not-a-list'},
        '/v1/banners': {'data': <dynamic>[]},
        '/v1/shops': {'data': <dynamic>[]},
        '/v1/challenges': {'data': <dynamic>[]},
        '/v1/member': {'data': 'not-a-map'},
      },
    );

    final result = await CatalogSync(dio, db).refresh();

    expect(result, isA<FailureResult<void>>());
    final after = await db.catalogDao.loadCatalog();
    expect(after.products.length, before.products.length);
  });
}

List<Map<String, dynamic>> _envelopeList(List<Map<String, dynamic>> items) =>
    List<Map<String, dynamic>>.from(items);

final _products = <Map<String, dynamic>>[
  {
    'id': 'p_coconut',
    'code': 'JD022123',
    'name': 'Coconut Donut',
    'priceMmk': 3200,
    'isNew': true,
    'discountPercent': null,
    'imageUrl': 'assets/seed/images/donut_coconut.png',
    'description': 'Toasted coconut.',
    'section': 'seasonal',
  },
];

final _banners = <Map<String, dynamic>>[
  {'id': 'b_1', 'imageUrl': 'assets/seed/images/banner_specials.png', 'title': 'Specials', 'sortOrder': 0},
];

final _shops = <Map<String, dynamic>>[
  {
    'id': 's_1',
    'name': 'Downtown',
    'address': '1 Main St',
    'distanceLabel': '0.4 km',
    'imageUrl': 'assets/seed/images/shop_city.png',
    'isOpen': true,
  },
];

final _challenges = <Map<String, dynamic>>[
  {'id': 'ch_donuts', 'title': 'Eat 4 donuts', 'kind': 'donut', 'current': 1, 'target': 4},
];

final _member = <String, dynamic>{
  'id': 'me',
  'name': 'Su Su Hlaing',
  'photoUrl': 'assets/seed/images/avatar.png',
  'tier': 'silver',
  'points': 680000,
  'notificationsCount': 3,
};
