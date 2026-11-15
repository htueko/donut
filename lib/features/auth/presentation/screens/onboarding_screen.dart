import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: AppMotion.emphasis,
  );
  late final AnimationController _drift = AnimationController(
    vsync: this,
    duration: AppMotion.ambient,
  );

  @override
  void initState() {
    super.initState();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _drift.repeat();
    }
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    _drift.dispose();
    super.dispose();
  }

  Animation<double> _fade(double start, double end) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(start, end, curve: AppMotion.decelerate),
    );
  }

  Animation<Offset> _rise(double start, double end) {
    return Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: Interval(start, end, curve: AppMotion.emphasized),
      ),
    );
  }

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _entrance,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned.fill(child: _Illustration(drift: _drift)),
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 5),
                        _FadeRise(
                          fade: _fade(0.35, 0.7),
                          rise: _rise(0.35, 0.7),
                          child: Text(
                            l10n?.onboardingTitle ??
                                'Round food for every mood',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.displayLarge
                                ?.copyWith(fontSize: 30),
                          ),
                        ),
                        const Spacer(flex: 6),
                        _FadeRise(
                          fade: _fade(0.55, 0.9),
                          rise: _rise(0.55, 0.9),
                          child: PrimaryButton(
                            label: l10n?.getStarted ?? 'Let\'s get started',
                            onPressed: () => context.go('/register/phone'),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _FadeRise(
                          fade: _fade(0.65, 1),
                          rise: _rise(0.65, 1),
                          child: SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () => context.go('/login/phone'),
                              child: Text(l10n?.logIn ?? 'Log in'),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        _SocialRow(
                          fade: _fade(0.75, 1),
                          rise: _rise(0.75, 1),
                          onComingSoon: () => _showComingSoon(
                            l10n?.socialLoginComingSoon ?? 'Coming soon',
                          ),
                        ),
                        const Spacer(flex: 2),
                        _FadeRise(
                          fade: _fade(0.85, 1),
                          rise: _rise(0.85, 1),
                          child: _LegalLinks(
                            onComingSoon: () => _showComingSoon(
                              l10n?.legalComingSoon ?? 'Not part of the demo',
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FadeRise extends StatelessWidget {
  const _FadeRise({
    required this.fade,
    required this.rise,
    required this.child,
  });

  final Animation<double> fade;
  final Animation<Offset> rise;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: rise, child: child),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration({required this.drift});

  final AnimationController drift;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: drift,
      builder: (context, _) {
        final t = drift.value * math.pi * 2;
        return Stack(
          children: [
            Positioned(
              top: 40 + math.sin(t) * 10,
              left: 24 + math.cos(t) * 8,
              child: _DonutBlob(color: AppColors.glaze, size: 88),
            ),
            Positioned(
              top: 120 + math.cos(t) * 12,
              right: 16 + math.sin(t) * 8,
              child: _DonutBlob(color: AppColors.seed, size: 120),
            ),
            Positioned(
              top: 220 + math.sin(t + 1) * 10,
              left: 60 + math.cos(t + 1) * 10,
              child: _DonutBlob(color: AppColors.mint, size: 56),
            ),
            Center(
              child: Image.asset(
                'assets/seed/images/donut_coconut.png',
                height: 220,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _DonutBlob extends StatelessWidget {
  const _DonutBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: size * 0.4,
          height: size * 0.4,
          decoration: const BoxDecoration(
            color: AppColors.cream,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _SocialRow extends StatelessWidget {
  const _SocialRow({
    required this.fade,
    required this.rise,
    required this.onComingSoon,
  });

  final Animation<double> fade;
  final Animation<Offset> rise;
  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    return _FadeRise(
      fade: fade,
      rise: rise,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SocialButton(icon: const Text('G'), onTap: onComingSoon),
          const SizedBox(width: AppSpacing.md),
          _SocialButton(
            icon: const Icon(Icons.apple, color: AppColors.chocolate),
            onTap: onComingSoon,
          ),
          const SizedBox(width: AppSpacing.md),
          _SocialButton(
            icon: const Icon(Icons.facebook, color: AppColors.chocolate),
            onTap: onComingSoon,
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.onTap});

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.paper,
      shape: const CircleBorder(side: BorderSide(color: AppColors.hairline)),
      clipBehavior: Clip.antiAlias,
      child: IconButton(onPressed: onTap, icon: icon),
    );
  }
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks({required this.onComingSoon});

  final VoidCallback onComingSoon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(onPressed: onComingSoon, child: const Text('Terms of Use')),
        const Text('·', style: TextStyle(color: AppColors.latte)),
        TextButton(
          onPressed: onComingSoon,
          child: const Text('Privacy Policy'),
        ),
      ],
    );
  }
}
