import 'package:donut/app/theme/app_palette.dart';
import 'package:donut/app/theme/app_theme.dart';
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

  Future<void> pumpDark(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogDatabaseProvider.overrideWithValue(db),
          onlineStatusProvider.overrideWith((ref) => Stream<bool>.value(false)),
        ],
        child: MaterialApp(theme: AppTheme.dark, home: screen),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('home renders on the dark palette', (tester) async {
    await pumpDark(tester, const HomeScreen());

    final palette = Theme.of(tester.element(find.byType(HomeScreen)))
        .extension<AppPalette>();
    expect(palette?.background, AppPalette.dark.background);

    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('Silver'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rewards renders on the dark palette', (tester) async {
    await pumpDark(tester, const RewardsScreen());

    final palette = Theme.of(tester.element(find.byType(RewardsScreen)))
        .extension<AppPalette>();
    expect(palette?.background, AppPalette.dark.background);

    expect(find.text('Rewards'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the same widget tree themes differently per brightness', (
    tester,
  ) async {
    Color backgroundFor(ThemeData theme) =>
        theme.extension<AppPalette>()!.background;

    expect(backgroundFor(AppTheme.light), AppPalette.light.background);
    expect(backgroundFor(AppTheme.dark), AppPalette.dark.background);
    expect(backgroundFor(AppTheme.light), isNot(backgroundFor(AppTheme.dark)));
  });
}
