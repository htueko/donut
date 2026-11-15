import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../features/settings/presentation/settings_providers.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class DonutApp extends ConsumerStatefulWidget {
  const DonutApp({
    this.initialLocale,
    this.initialThemeMode = ThemeMode.system,
    super.key,
  });

  final Locale? initialLocale;
  final ThemeMode initialThemeMode;

  @override
  ConsumerState<DonutApp> createState() => _DonutAppState();
}

class _DonutAppState extends ConsumerState<DonutApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(localeProvider.notifier).state = widget.initialLocale;
      ref.read(themeModeProvider.notifier).state = widget.initialThemeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    // Keep intl in step with the selected locale so DateFormat/NumberFormat
    // calls without an explicit locale localize too.
    Intl.defaultLocale = locale?.toString();
    return MaterialApp.router(
      onGenerateTitle: (context) =>
          AppLocalizations.of(context)?.appTitle ?? 'J\u2019Donuts',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) =>
          MotionScope(child: child ?? const SizedBox.shrink()),
    );
  }
}

class MotionScope extends StatelessWidget {
  const MotionScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      minScaleFactor: 1,
      maxScaleFactor: 1.3,
      child: child,
    );
  }
}
