import 'package:donut/app/app.dart';
import 'package:donut/features/auth/data/auth_providers.dart';
import 'package:donut/features/auth/data/session_store.dart';
import 'package:donut/features/auth/presentation/auth_flow_provider.dart';
import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/support/asset_loader.dart';

/// In-memory stand-in for flutter_secure_storage.
class FakeSecureStorage implements SecureStorageGateway {
  final Map<String, String> _values = <String, String>{};

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

  @override
  Future<void> delete(String key) async => _values.remove(key);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('register, browse home, open a product detail', (tester) async {
    await useDiskAssets();
    final db = CatalogDatabase.inMemory();
    addTearDown(db.close);
    await seedCatalog(db);
    final storage = FakeSecureStorage();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogDatabaseProvider.overrideWithValue(db),
          sessionStoreProvider.overrideWithValue(SessionStore(storage)),
          initialSessionUserProvider.overrideWithValue(null),
        ],
        child: const DonutApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Round food for every mood'), findsOneWidget);

    await tester.tap(find.text('Let\'s get started'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField).first, '09254135592');
    await _settle(tester);
    await tester.tap(find.text('Continue'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField).first, '123456');
    await _settle(tester);
    await tester.tap(find.text('Continue'));
    await _settle(tester);

    await tester.enterText(find.byType(TextField).first, 'Su');
    await _settle(tester);
    await tester.tap(find.text('Continue'));
    await _settle(tester);

    await tester.tap(find.text('Select date'));
    await _settle(tester);
    await tester.tap(find.text('OK'));
    await _settle(tester);

    await tester.tap(find.text('Continue'));
    await _settle(tester);

    expect(find.text('Welcome to the world of J\'donuts'), findsOneWidget);
    await tester.tap(find.text('Let\'s explore'));
    await _settle(tester);

    expect(find.text('Seasonal specials'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Coconut Donut'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await _settle(tester);
    await tester.tap(find.text('Coconut Donut'));
    await _settle(tester);

    expect(find.text('Code JD022123'), findsOneWidget);
    expect(find.text('3,200 MMK'), findsNWidgets(2));
  });
}

/// The onboarding illustration animates forever, so settle the finite pieces and
/// then let looping animations run without waiting on them.
Future<void> _settle(WidgetTester tester, {int frames = 16}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
