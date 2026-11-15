import 'package:donut/features/catalog/data/catalog_providers.dart';
import 'package:donut/features/catalog/data/local/catalog_database.dart'
    hide Banner, Challenge, Member, Product, Shop;
import 'package:donut/features/rewards/presentation/rewards_screen.dart';
import 'package:donut/features/rewards/presentation/widgets/challenge_painters.dart';
import 'package:donut/features/rewards/presentation/widgets/points_ring.dart';
import 'package:donut/features/rewards/presentation/widgets/reward_tabs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/asset_loader.dart';

// Painter fixtures: raw colors are fine here because the painters are handed
// theme colors by the widgets that own them.
const Color pink = Color(0xFFFF5398);
const Color grey = Color(0xFFB5B8BD);
const Color orange = Color(0xFFFF7E27);
const Color yellow = Color(0xFFE5C158);
const Color green = Color(0xFF74C69D);
const Color white = Color(0xFFFFFFFF);

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

  Future<void> pumpRewards(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [catalogDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: RewardsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  testWidgets(
    'shows member points and both challenge cards from the database',
    (tester) async {
      await pumpRewards(tester);

      expect(find.text('680,000'), findsOneWidget);
      expect(find.text('Su Su Hlaing'), findsOneWidget);
      expect(find.text('Eat 4 donuts this week'), findsOneWidget);
      expect(find.text('Collect 12 coffee stamps'), findsOneWidget);
    },
  );

  testWidgets('only the completed challenge is earnable', (tester) async {
    await pumpRewards(tester);

    expect(find.text('1/4'), findsOneWidget);
    expect(find.text('9/12'), findsOneWidget);
    expect(find.text('Earn'), findsNWidgets(2));
    expect(find.byIcon(Icons.check), findsWidgets);
  });

  testWidgets('switching tabs swaps the list and keeps the challenge tab', (
    tester,
  ) async {
    await pumpRewards(tester);

    await tester.scrollUntilVisible(
      find.text('Gift'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Gift'));
    await tester.pumpAndSettle();

    expect(find.text('Eat 4 donuts this week'), findsNothing);
    expect(find.byIcon(Icons.card_giftcard_outlined), findsWidgets);

    await tester.tap(find.text('Eat more earn more'));
    await tester.pumpAndSettle();

    expect(find.text('Eat 4 donuts this week'), findsOneWidget);
  });

  testWidgets('ring painter reports the swept fraction', (tester) async {
    const painter = PointsRingPainter(
      progress: 0.5,
      active: pink,
      track: grey,
      mid: orange,
      highlight: yellow,
    );
    final repaint = painter.shouldRepaint(
      const PointsRingPainter(
        progress: 0.4,
        active: pink,
        track: grey,
        mid: orange,
        highlight: yellow,
      ),
    );
    expect(repaint, isTrue);
  });

  testWidgets('quarter painter fills one quarter per item', (tester) async {
    const size = Size(60, 60);
    final canvas = _RecordingCanvas();
    const DonutQuarterPainter(
      fill: 0.25,
      complete: false,
      track: grey,
      progress: pink,
      success: green,
      center: white,
      onProgress: white,
    ).paint(canvas, size);
    expect(canvas.arcs, 1);
  });

  testWidgets('gift panel renders its placeholder message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GiftPanel(message: 'Nothing here')),
      ),
    );
    expect(find.text('Nothing here'), findsOneWidget);
  });
}

class _RecordingCanvas implements Canvas {
  int arcs = 0;

  @override
  void drawArc(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool useCenter,
    Paint paint,
  ) {
    arcs++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
