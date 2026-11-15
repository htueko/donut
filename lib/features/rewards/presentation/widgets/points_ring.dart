import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';

/// Sweeps a ring from empty to [progress] while a total counts up from 0.
class PointsRing extends StatefulWidget {
  const PointsRing({
    required this.progress,
    required this.total,
    required this.centerLabel,
    this.size = 148,
    this.sweep = AppMotion.emphasis,
    super.key,
  });

  final double progress;
  final int total;
  final String centerLabel;
  final double size;
  final Duration sweep;

  @override
  State<PointsRing> createState() => _PointsRingState();
}

class _PointsRingState extends State<PointsRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.sweep,
  );
  late final Animation<double> _sweep = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.emphasized,
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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_sweep, _controller]),
      builder: (context, _) {
        // One 0→1 timeline drives both the arc and the count-up, so the ring
        // ends at the member's tier progress while the number lands on the
        // full point total.
        final t = motionValue(_sweep, context);
        final sweep = widget.progress * t;
        final points = (widget.total * t).round();
        return SizedBox.square(
          dimension: widget.size,
          child: CustomPaint(
            painter: PointsRingPainter(progress: sweep, active: AppColors.seed),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    PointsRingPainter.formatPoints(points),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.chocolate,
                    ),
                  ),
                  Text(
                    widget.centerLabel,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.cocoa,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PointsRingPainter extends CustomPainter {
  const PointsRingPainter({required this.progress, required this.active});

  static const double stroke = 12;

  static final NumberFormat _decimal = NumberFormat.decimalPattern('en');

  static String formatPoints(int points) => _decimal.format(points);

  final double progress;
  final Color active;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - stroke) / 2;
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = AppColors.hairline;
    canvas.drawCircle(center, radius, track);

    final sweep = progress.clamp(0.0, 1.0) * math.pi * 2;
    const gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: math.pi * 1.5,
      colors: [AppColors.seed, AppColors.caramel, AppColors.glaze],
      stops: [0, 0.6, 1],
    );
    final fill = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweep,
      false,
      fill,
    );
  }

  @override
  bool shouldRepaint(PointsRingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.active != active;
}

/// Segmented tier track: Silver → Gold → Platinum with a fill up to the member's
/// progress and the current tier called out.
class TierLadder extends StatelessWidget {
  const TierLadder({
    required this.tiers,
    required this.currentIndex,
    required this.fractionIntoTier,
    super.key,
  });

  final List<String> tiers;
  final int currentIndex;
  final double fractionIntoTier;

  @override
  Widget build(BuildContext context) {
    const node = 18.0;
    const trackHeight = 4.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final usable = width - node;
        final step = tiers.length <= 1 ? usable : usable / (tiers.length - 1);
        final fillEnd = (currentIndex + fractionIntoTier.clamp(0.0, 1.0)) * step;
        return SizedBox(
          height: node,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: node / 2,
                right: width - node / 2,
                top: (node - trackHeight) / 2,
                child: Container(height: trackHeight, color: AppColors.hairline),
              ),
              Positioned(
                left: node / 2,
                top: (node - trackHeight) / 2,
                width: fillEnd.clamp(0.0, usable),
                child: Container(
                  height: trackHeight,
                  decoration: BoxDecoration(
                    color: AppColors.seed,
                    borderRadius: BorderRadius.circular(trackHeight),
                  ),
                ),
              ),
              for (var i = 0; i < tiers.length; i++)
                Positioned(
                  left: i * step,
                  top: 0,
                  child: _TierNode(
                    label: tiers[i],
                    reached: i <= currentIndex,
                    current: i == currentIndex,
                    color: AppColors.tierColor(tiers[i].toLowerCase()),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TierNode extends StatelessWidget {
  const _TierNode({
    required this.label,
    required this.reached,
    required this.current,
    required this.color,
  });

  final String label;
  final bool reached;
  final bool current;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: reached ? color : AppColors.paper,
        border: Border.all(color: reached ? color : AppColors.hairline, width: 2),
        boxShadow: current
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: reached
          ? const Icon(Icons.check, size: 11, color: Colors.white)
          : null,
    );
    if (!current) {
      return dot;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        dot,
        const SizedBox(height: AppSpacing.xs),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 96),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
