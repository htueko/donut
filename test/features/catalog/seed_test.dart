import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('seeds the catalog into the database on first run only', () async {
    final db = CatalogDatabase.inMemory();
    addTearDown(db.close);

    await seedCatalog(db);
    final first = await db.catalogDao.loadCatalog();

    expect(first.products, isNotEmpty);
    expect(first.banners, isNotEmpty);
    expect(first.shops, hasLength(4));
    expect(first.member, isNotNull);
    expect(first.member?.points, 680000);

    await seedCatalog(db);
    final second = await db.catalogDao.loadCatalog();

    expect(second.products.length, first.products.length);
    expect(second.member?.id, first.member?.id);
  });

  test('seeds all products with the expected shape', () async {
    final db = CatalogDatabase.inMemory();
    addTearDown(db.close);

    await seedCatalog(db);
    final data = await db.catalogDao.loadCatalog();

    final coconut = data.productById('p_coconut');
    expect(coconut, isNotNull);
    expect(coconut?.code, 'JD022123');
    expect(coconut?.priceMmk, 3200);
    expect(coconut?.isNew, isTrue);
  });
}
