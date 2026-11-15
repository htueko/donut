import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  static const _donuts = <String>[
    'donut_coconut.png',
    'donut_strawberry.png',
    'donut_chocolate.png',
    'donut_matcha.png',
    'donut_caramel.png',
    'donut_mango.png',
    'donut_blueberry.png',
    'donut_redvelvet.png',
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.emphasis,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
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
                child: GridView.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    for (var i = 0; i < _donuts.length; i++)
                      FadeTransition(
                        opacity: _fade(0.05 + i * 0.05),
                        child: SlideTransition(
                          position: _rise(0.05 + i * 0.05),
                          child: Image.asset(
                            'assets/seed/images/${_donuts[i]}',
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _fade(0.6),
                child: SlideTransition(
                  position: _rise(0.6),
                  child: Text(
                    l10n?.welcomeTitle ?? 'Welcome to the world of J\'donuts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
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
