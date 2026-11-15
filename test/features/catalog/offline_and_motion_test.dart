import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart'
    hide Banner, Challenge, Member, Product, Shop;
import 'package:donut/features/home/presentation/home_screen.dart';
import 'package:donut/features/rewards/presentation/rewards_screen.dart';
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

  Future<void> pumpOfflineHome(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogDatabaseProvider.overrideWithValue(db),
          onlineStatusProvider.overrideWith((ref) => Stream<bool>.value(false)),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home renders from the database with no network at all', (
    tester,
  ) async {
    await pumpOfflineHome(tester);

    expect(find.text('You\'re offline'), findsOneWidget);
    expect(find.text('Su Su Hlaing'), findsOneWidget);
    expect(find.text('Silver'), findsOneWidget);
    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('Coconut Donut'), findsOneWidget);
  });

  testWidgets('rewards render from the database with no network at all', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogDatabaseProvider.overrideWithValue(db),
          onlineStatusProvider.overrideWith((ref) => Stream<bool>.value(false)),
        ],
        child: const MaterialApp(home: RewardsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 120));
    }

    expect(find.text('680,000'), findsOneWidget);
    expect(find.text('Eat 4 donuts this week'), findsOneWidget);
  });

  testWidgets('reduce motion lands every animation on its end state', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: RewardsScreen(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Ring total, challenge counts and cards are all fully drawn immediately.
    expect(find.text('680,000'), findsOneWidget);
    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('9/12'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
