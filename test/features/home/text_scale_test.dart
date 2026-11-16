import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart'
    hide Banner, Challenge, Member, Product, Shop;
import 'package:donut/features/home/presentation/home_screen.dart';
import 'package:donut/features/product/presentation/product_detail_screen.dart';
import 'package:donut/features/rewards/presentation/rewards_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/asset_loader.dart';

/// The brief asks for phone layouts at 1.3× text scale without overflow, so each
/// primary screen is laid out at that scale and must render an exception-free
/// frame.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogDatabase db;

  setUp(() async {
    await useDiskAssets();
    db = CatalogDatabase.inMemory();
    await seedCatalog(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpAt(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.7;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
            child: screen,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('home renders at 1.3x text scale without overflow', (
    tester,
  ) async {
    await pumpAt(tester, const HomeScreen());
    expect(tester.takeException(), isNull);
    expect(find.text('Seasonal specials'), findsOneWidget);
  });

  testWidgets('product detail renders at 1.3x text scale', (tester) async {
    await pumpAt(tester, const ProductDetailScreen(productId: 'p_coconut'));
    expect(tester.takeException(), isNull);
    expect(find.text('Coconut Donut'), findsOneWidget);
  });

  testWidgets('rewards renders at 1.3x text scale', (tester) async {
    await pumpAt(tester, const RewardsScreen());
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }
    expect(tester.takeException(), isNull);
    expect(find.text('Eat 4 donuts this week'), findsOneWidget);
  });
}
