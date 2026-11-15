import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart'
    hide Banner, Challenge, Member, Product, Shop;
import 'package:donut/features/product/presentation/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/asset_loader.dart';

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

  Future<void> pumpScreen(WidgetTester tester, {String id = 'p_coconut'}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: ProductDetailScreen(productId: id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> scrollToStepper(WidgetTester tester) async {
    await tester.dragUntilVisible(
      find.byIcon(Icons.add),
      find.byType(Scrollable).first,
      const Offset(0, -120),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders product data from the database', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Coconut Donut'), findsOneWidget);
    expect(find.text('Code JD022123'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsOneWidget);
    expect(find.text('What\'s this?'), findsOneWidget);
    expect(find.textContaining('fresh coconut flakes'), findsOneWidget);
  });

  testWidgets('quantity stepper multiplies the live total', (tester) async {
    await pumpScreen(tester);
    await scrollToStepper(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('6,400 MMK'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.text('9,600 MMK'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    expect(find.text('6,400 MMK'), findsOneWidget);
  });

  testWidgets('stepper never drops below the minimum of 1', (tester) async {
    await pumpScreen(tester);
    await scrollToStepper(tester);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();

    expect(find.text('1'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsNWidgets(2));
  });

  testWidgets('add to cart reports the quantity as feedback', (tester) async {
    await pumpScreen(tester);
    await scrollToStepper(tester);

    await tester.tap(find.text('Add to cart'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('1 added to cart'), findsOneWidget);
  });

  testWidgets('shows a not-found state for an unknown product id', (tester) async {
    await pumpScreen(tester, id: 'p_missing');

    expect(find.text('Not found'), findsOneWidget);
  });
}
