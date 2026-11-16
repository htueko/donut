import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const _donuts = <_DonutTileData>[
    _DonutTileData(
      asset: 'assets/seed/images/donut_coconut.png',
      color: Color(0xFFE3F2FD),
    ),
    _DonutTileData(
      asset: 'assets/seed/images/donut_strawberry.png',
      color: Color(0xFFFCE4EC),
    ),
    _DonutTileData(
      asset: 'assets/seed/images/donut_chocolate.png',
      color: Color(0xFFFFF3E0),
    ),
    _DonutTileData(
      asset: 'assets/seed/images/donut_matcha.png',
      color: Color(0xFFFFFDE7),
    ),
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.emphasis,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    animateOnce(_controller, context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1, curve: AppMotion.decelerate),
    );
  }

  Animation<Offset> _rise(double start) {
    return Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(start, 1, curve: AppMotion.emphasized),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.lg,
                    crossAxisSpacing: AppSpacing.lg,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      for (var i = 0; i < _donuts.length; i++)
                        FadeTransition(
                          opacity: _fade(0.08 + i * 0.1),
                          child: SlideTransition(
                            position: _rise(0.08 + i * 0.1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _donuts[i].color,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusLg,
                                ),
                              ),
                              padding: const EdgeInsets.all(AppSpacing.lg),
                              child: Center(
                                child: Image.asset(
                                  _donuts[i].asset,
                                  filterQuality: FilterQuality.medium,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              FadeTransition(
                opacity: _fade(0.6),
                child: SlideTransition(
                  position: _rise(0.6),
                  child: Text(
                    l10n?.welcomeTitle ?? 'Welcome to the world of J\'donuts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: AppTypography.h1Weight),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              FadeTransition(
                opacity: _fade(0.8),
                child: SlideTransition(
                  position: _rise(0.8),
                  child: PrimaryButton(
                    label: l10n?.letsExplore ?? 'Let\'s explore',
                    onPressed: () => context.go('/home'),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _DonutTileData {
  const _DonutTileData({required this.asset, required this.color});

  final String asset;
  final Color color;
}
