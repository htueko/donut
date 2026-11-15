import 'package:donut/features/auth/data/session_store.dart';
import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart'
    hide Banner, Challenge, Member, Product, Shop;
import 'package:donut/features/home/presentation/home_screen.dart';
import 'package:donut/features/rewards/presentation/rewards_screen.dart';
import 'package:donut/features/settings/presentation/settings_providers.dart';
import 'package:donut/features/settings/presentation/settings_screen.dart';
import 'package:donut/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/asset_loader.dart';

class _InMemoryStorage implements SecureStorageGateway {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String? value) async {
    if (value == null) {
      _values.remove(key);
    } else {
      _values[key] = value;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CatalogDatabase db;
  late _InMemoryStorage storage;

  setUp(() async {
    await useDiskAssets();
    db = CatalogDatabase.inMemory();
    await seedCatalog(db);
    storage = _InMemoryStorage();
  });

  tearDown(() async {
    await db.close();
  });

  Widget wrap(Widget home, {Locale? locale}) {
    return ProviderScope(
      overrides: [
        catalogDatabaseProvider.overrideWithValue(db),
        onlineStatusProvider.overrideWith((ref) => Stream<bool>.value(false)),
        settingsStorageProvider.overrideWithValue(storage),
        localeProvider.overrideWith((ref) => locale),
      ],
      child: MaterialApp(
        locale: locale,
        theme: ThemeData(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: home,
      ),
    );
  }

  testWidgets('home renders Burmese labels when the Myanmar locale is active', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const HomeScreen(), locale: const Locale('my')),
    );
    await tester.pumpAndSettle();

    expect(find.text('ရာသီအလိုက် အထူးများ'), findsOneWidget);
    expect(find.text('ငွေ'), findsOneWidget);
    expect(find.text('အင်တာနက် မရှိပါ'), findsOneWidget);
    expect(find.text('Seasonal specials'), findsNothing);
    // Prices carry the localized currency unit and Burmese digits.
    expect(find.textContaining('ကျပ်'), findsWidgets);
    expect(find.textContaining('MMK'), findsNothing);
    // Discount badges localize their digits too (seeded 10/15/20 percent).
    expect(find.textContaining('-၁၀%'), findsWidgets);
    expect(find.textContaining('% off'), findsNothing);
  });

  testWidgets('rewards renders Burmese tier ladder and points label', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const RewardsScreen(), locale: const Locale('my')),
    );
    await tester.pumpAndSettle();

    expect(find.text('ဆုလက်ဆောင်များ'), findsOneWidget);
    expect(find.text('မှတ်'), findsOneWidget);
    // The seeded member is Silver: once on the tier badge, once as the current
    // ladder node (only the current node carries a label).
    expect(find.text('ငွေ'), findsNWidgets(2));
    expect(find.text('Silver'), findsNothing);
    expect(find.text('points'), findsNothing);
  });

  testWidgets('english stays the default locale', (tester) async {
    await tester.pumpWidget(wrap(const HomeScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Seasonal specials'), findsOneWidget);
    expect(find.text('Silver'), findsOneWidget);
    expect(find.textContaining('MMK'), findsWidgets);
  });

  testWidgets(
    'choosing Myanmar in settings switches the locale and persists it',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          catalogDatabaseProvider.overrideWithValue(db),
          settingsStorageProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Myanmar'));
      await tester.pumpAndSettle();

      expect(container.read(localeProvider), const Locale('my'));
      expect(await storage.read('settings_locale'), 'my');
    },
  );
}
