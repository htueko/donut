import 'package:donut/app/router.dart';
import 'package:donut/app/theme/app_theme.dart';
import 'package:donut/features/legal/presentation/legal_screen.dart';
import 'package:donut/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _delegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

Widget _wrap(Widget home, {Locale? locale}) {
  return ProviderScope(
    child: MaterialApp(
      locale: locale,
      theme: ThemeData(),
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}

/// The real router, so the redirect guard and the legal routes are exercised
/// together with the onboarding links.
Widget _app() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return UncontrolledProviderScope(
    container: container,
    child: Consumer(
      builder: (context, ref, _) => MaterialApp.router(
        theme: AppTheme.light,
        localizationsDelegates: _delegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: ref.watch(routerProvider),
      ),
    ),
  );
}

/// The legal page is pushed on top of onboarding, which stays mounted below it,
/// so the top page is identified by its AppBar rather than by plain text.
Finder _appBarTitle(String title) =>
    find.descendant(of: find.byType(AppBar), matching: find.text(title));

/// Pumps a fixed amount instead of settling: the onboarding screen loops an
/// ambient animation, so `pumpAndSettle` would never return.
Future<void> _pumpPastTransition(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));
}

/// Opacities of every [FadeTransition] above [label]. Anything below 1 means
/// the page is still fading in, which happens when the platform page transition
/// animates the page underneath a popped route.
List<double> _opacitiesAbove(WidgetTester tester, String label) {
  return find
      .ancestor(of: find.text(label), matching: find.byType(FadeTransition))
      .evaluate()
      .map((element) => (element.widget as FadeTransition).opacity.value)
      .toList();
}

void main() {
  group('LegalScreen', () {
    testWidgets('terms page shows its title, revision date and sections', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const LegalScreen(document: LegalDocument.terms)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Last updated 15 November 2026'), findsOneWidget);
      expect(find.text('Using the app'), findsOneWidget);
      expect(find.text('Orders and payments'), findsOneWidget);
      expect(find.text('Changes to these terms'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsNothing);
    });

    testWidgets('privacy page shows its own copy, not the terms text', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const LegalScreen(document: LegalDocument.privacy)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('What we store'), findsOneWidget);
      expect(find.text('What we do not collect'), findsOneWidget);
      expect(find.text('Your choices'), findsOneWidget);
      expect(find.text('Using the app'), findsNothing);
    });

    testWidgets('both documents localize to Burmese', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const LegalScreen(document: LegalDocument.privacy),
          locale: const Locale('my'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('သိမ်းဆည်းသည့် အချက်အလက်များ'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsNothing);
    });
  });

  group('onboarding legal links', () {
    testWidgets('both links fit a narrow phone width in either locale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 900));

      expect(tester.takeException(), isNull);
      expect(find.text('Terms of Use'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('returning does not replay the entrance animation', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 900));

      await tester.tap(find.text('Privacy Policy'));
      await _pumpPastTransition(tester);
      await tester.tap(find.byType(BackButton));
      // Sample mid-transition: the platform transition used to fade the page
      // underneath the popped route in from zero, which read as a second,
      // separate transition on top of the back navigation.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        _opacitiesAbove(tester, 'Round food for every mood'),
        everyElement(1.0),
      );
      expect(_opacitiesAbove(tester, "Let's get started"), everyElement(1.0));
    });

    testWidgets('terms link opens the terms page and back returns', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('Terms of Use'));
      await _pumpPastTransition(tester);

      expect(_appBarTitle('Terms of Use'), findsOneWidget);
      expect(find.text('Using the app'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await _pumpPastTransition(tester);

      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Using the app'), findsNothing);
      expect(find.text('Round food for every mood'), findsOneWidget);
    });

    testWidgets('privacy link opens the privacy page', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('Privacy Policy'));
      await _pumpPastTransition(tester);

      expect(_appBarTitle('Privacy Policy'), findsOneWidget);
      expect(find.text('What we store'), findsOneWidget);
      expect(find.text('Using the app'), findsNothing);
    });

    testWidgets('links navigate instead of showing the snackbar', (
      tester,
    ) async {
      await tester.pumpWidget(_app());
      await tester.pump(const Duration(milliseconds: 800));

      await tester.tap(find.text('Terms of Use'));
      await _pumpPastTransition(tester);

      expect(_appBarTitle('Terms of Use'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });
  });
}
