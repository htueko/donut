import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class RegistrationProgressRing extends StatefulWidget {
  const RegistrationProgressRing({
    required this.step,
    required this.total,
    super.key,
  });

  final int step;
  final int total;

  @override
  State<RegistrationProgressRing> createState() =>
      _RegistrationProgressRingState();
}

class _RegistrationProgressRingState extends State<RegistrationProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );
  late Animation<double> _sweep;

  bool get _complete => widget.step >= widget.total;

  @override
  void initState() {
    super.initState();
    _controller.value = 1;
    _buildSweep();
  }

  @override
  void didUpdateWidget(RegistrationProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _buildSweep();
      _controller.forward(from: 0);
    }
  }

  void _buildSweep() {
    _sweep =
        Tween<double>(
          begin: _fractionFor(widget.step - 1),
          end: _fractionFor(widget.step),
        ).animate(
          CurvedAnimation(parent: _controller, curve: AppMotion.emphasized),
        );
  }

  double _fractionFor(int step) {
    if (step <= 0) {
      return 0;
    }
    return (step / widget.total).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final palette = context.palette;
    return AnimatedSwitcher(
      duration: motionScale(context, AppMotion.base),
      switchInCurve: AppMotion.standard,
      child: _complete
          ? _CheckBadge(
              background: palette.success,
              foreground: palette.onPrimary,
            )
          : SizedBox.square(
              dimension: AppSpacing.iconMd,
              child: AnimatedBuilder(
                animation: _sweep,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RingPainter(
                      progress: reduceMotion
                          ? _fractionFor(widget.step)
                          : _sweep.value,
                      track: palette.border,
                      fill: palette.primary,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.step}/${widget.total}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: AppTypography.h2Weight,
                          color: palette.textPrimary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
  });

  static const double _stroke = 3.5;

  final double progress;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      _stroke / 2,
      _stroke / 2,
      size.width - _stroke,
      size.height - _stroke,
    );
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    final fillPaint = Paint()
      ..color = fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      fillPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.track != track ||
      oldDelegate.fill != fill;
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge({required this.background, required this.foreground});

  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.iconMd,
      height: AppSpacing.iconMd,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(Icons.check, color: foreground, size: AppSpacing.iconSm),
    );
  }
}
