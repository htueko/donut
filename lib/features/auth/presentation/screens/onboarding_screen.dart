import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _drift.repeat();
    } else {
      _drift.stop();
      _drift.value = 1;
    }
    _entrance.forward(from: 0);
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
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontSize: AppTypography.onboardingTitleSize,
                                ),
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

/// Fixed geometry for the decorative donut illustration.
abstract final class _Layout {
  static const double blobOneTop = 40;
  static const double blobOneLeft = 24;
  static const double blobOneSize = 88;
  static const double blobOneFloatY = 10;
  static const double blobOneFloatX = 8;

  static const double blobTwoTop = 120;
  static const double blobTwoRight = 16;
  static const double blobTwoSize = 120;
  static const double blobTwoFloatY = 12;
  static const double blobTwoFloatX = 8;

  static const double blobThreeTop = 220;
  static const double blobThreeLeft = 60;
  static const double blobThreeSize = 56;
  static const double blobThreeFloatY = 10;
  static const double blobThreeFloatX = 10;

  static const double heroImageHeight = 220;
  static const double blobHoleRatio = 0.4;
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
              top: _Layout.blobOneTop + math.sin(t) * _Layout.blobOneFloatY,
              left: _Layout.blobOneLeft + math.cos(t) * _Layout.blobOneFloatX,
              child: _DonutBlob(
                color: context.palette.warning,
                size: _Layout.blobOneSize,
              ),
            ),
            Positioned(
              top: _Layout.blobTwoTop + math.cos(t) * _Layout.blobTwoFloatY,
              right: _Layout.blobTwoRight + math.sin(t) * _Layout.blobTwoFloatX,
              child: _DonutBlob(
                color: context.palette.primary,
                size: _Layout.blobTwoSize,
              ),
            ),
            Positioned(
              top:
                  _Layout.blobThreeTop +
                  math.sin(t + 1) * _Layout.blobThreeFloatY,
              left:
                  _Layout.blobThreeLeft +
                  math.cos(t + 1) * _Layout.blobThreeFloatX,
              child: _DonutBlob(
                color: context.palette.success,
                size: _Layout.blobThreeSize,
              ),
            ),
            Center(
              child: Image.asset(
                'assets/seed/images/donut_coconut.png',
                height: _Layout.heroImageHeight,
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
          width: size * _Layout.blobHoleRatio,
          height: size * _Layout.blobHoleRatio,
          decoration: BoxDecoration(
            color: context.palette.background,
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
            icon: Icon(Icons.apple, color: context.palette.textPrimary),
            onTap: onComingSoon,
          ),
          const SizedBox(width: AppSpacing.md),
          _SocialButton(
            icon: Icon(Icons.facebook, color: context.palette.textPrimary),
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
    final palette = context.palette;
    return Material(
      color: palette.surface,
      shape: CircleBorder(side: BorderSide(color: palette.border)),
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
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onComingSoon,
          child: Text(l10n?.termsOfUse ?? 'Terms of Use'),
        ),
        Text('·', style: TextStyle(color: context.palette.textMuted)),
        TextButton(
          onPressed: onComingSoon,
          child: Text(l10n?.privacyPolicy ?? 'Privacy Policy'),
        ),
      ],
    );
  }
}
