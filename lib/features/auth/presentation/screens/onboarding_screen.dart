import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _entranceStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!MediaQuery.disableAnimationsOf(context)) {
      if (!_drift.isAnimating) {
        _drift.repeat();
      }
    } else {
      _drift.stop();
      _drift.value = 1;
    }
    if (!_entranceStarted) {
      _entranceStarted = true;
      _entrance.forward(from: 0);
    }
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
    final palette = context.palette;
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final overlayStyle = Theme.of(context).brightness == Brightness.dark
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: overlayStyle.statusBarIconBrightness,
        statusBarBrightness: overlayStyle.statusBarBrightness,
      ),
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _entrance,
          builder: (context, _) {
            return Stack(
              children: [
                Positioned.fill(child: _Illustration(drift: _drift)),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      topPadding,
                      AppSpacing.xl,
                      AppSpacing.md + bottomPadding,
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
                                  fontWeight: AppTypography.h1Weight,
                                ),
                          ),
                        ),
                        const Spacer(flex: 5),
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
                          child: GestureDetector(
                            onTap: () => context.go('/login/phone'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.xs,
                              ),
                              child: Text.rich(
                                TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: palette.textSecondary),
                                  children: [
                                    const TextSpan(
                                      text: 'Already have an account? ',
                                    ),
                                    TextSpan(
                                      text: l10n?.logIn ?? 'Log In',
                                      style: TextStyle(
                                        color: palette.primary,
                                        fontWeight: AppTypography.h2Weight,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
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
                            onTerms: () => context.push('/legal/terms'),
                            onPrivacy: () => context.push('/legal/privacy'),
                          ),
                        ),
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
            // Floating background blobs with donut images inside
            Positioned(
              top: 30 + math.sin(t) * 10,
              left: 20 + math.cos(t) * 8,
              child: const _DonutFloatCard(
                color: Color(0xFFFFEBF0),
                imageAsset: 'assets/seed/images/donut_strawberry.png',
                size: 90,
              ),
            ),
            Positioned(
              top: 100 + math.cos(t) * 12,
              right: 16 + math.sin(t) * 8,
              child: const _DonutFloatCard(
                color: Color(0xFFE8F7FB),
                imageAsset: 'assets/seed/images/donut_chocolate.png',
                size: 110,
              ),
            ),
            Positioned(
              top: 200 + math.sin(t + 1) * 10,
              left: 50 + math.cos(t + 1) * 10,
              child: const _DonutFloatCard(
                color: Color(0xFFFFF4E5),
                imageAsset: 'assets/seed/images/donut_matcha.png',
                size: 70,
              ),
            ),
            Positioned(
              top: 190 + math.cos(t + 1.5) * 8,
              right: 40 + math.sin(t + 1.5) * 8,
              child: const _DonutFloatCard(
                color: Color(0xFFF3E8FF),
                imageAsset: 'assets/seed/images/donut_mango.png',
                size: 65,
              ),
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

class _DonutFloatCard extends StatelessWidget {
  const _DonutFloatCard({
    required this.color,
    required this.imageAsset,
    required this.size,
  });

  final Color color;
  final String imageAsset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.12),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Image.asset(imageAsset, filterQuality: FilterQuality.medium),
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
          _SocialButton(
            icon: const SizedBox(
              width: 22,
              height: 22,
              child: CustomPaint(painter: _GoogleIconPainter()),
            ),
            onTap: onComingSoon,
          ),
          const SizedBox(width: AppSpacing.md),
          _SocialButton(
            icon: Icon(
              Icons.apple,
              color: context.palette.textPrimary,
              size: 24,
            ),
            onTap: onComingSoon,
          ),
          const SizedBox(width: AppSpacing.md),
          _SocialButton(
            icon: const Icon(
              Icons.facebook,
              color: Color(0xFF1877F2),
              size: 24,
            ),
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
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: icon,
        ),
      ),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  const _GoogleIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final stroke = size.width * 0.22;
    final rect = Rect.fromCircle(center: center, radius: radius - stroke / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    // Red (top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -math.pi * 0.75, math.pi * 0.5, false, paint);

    // Yellow (left)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, math.pi * 0.75, math.pi * 0.5, false, paint);

    // Green (bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, math.pi * 0.25, math.pi * 0.5, false, paint);

    // Blue (right)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -math.pi * 0.25, math.pi * 0.5, false, paint);

    final linePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;
    canvas.drawLine(
      center,
      Offset(center.dx + radius - stroke / 2, center.dy),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegalLinks extends StatelessWidget {
  const _LegalLinks({required this.onTerms, required this.onPrivacy});

  final VoidCallback onTerms;
  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final palette = context.palette;
    final termsText = l10n?.termsOfUse ?? 'Terms of Use';
    final privacyText = l10n?.privacyPolicy ?? 'Privacy Policy';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Text.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: palette.textMuted, fontSize: 11),
          children: [
            const TextSpan(
              text: 'By continuing, you acknowledge that you have read and agree to our ',
            ),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onTerms,
                child: Text(
                  termsText,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' and '),
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: GestureDetector(
                onTap: onPrivacy,
                child: Text(
                  privacyText,
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 11,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
