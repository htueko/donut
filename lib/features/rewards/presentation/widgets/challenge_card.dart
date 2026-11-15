import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../catalog/domain/catalog_enums.dart';
import '../../../catalog/domain/challenge.dart';

/// A challenge card whose artwork fills in by quarters: the donut fills one
/// quarter per completed item, the coffee arc sweeps to the cup's fill line.
class ChallengeCard extends StatefulWidget {
  const ChallengeCard({required this.challenge, this.rewardLabel, super.key});

  final Challenge challenge;
  final String? rewardLabel;

  @override
  State<ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<ChallengeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
  );
  late final Animation<double> _enter = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.emphasized,
  );
  late final Animation<double> _fill = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.standard,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final enter = reduced ? 1.0 : _enter.value;
        final fill = reduced ? widget.challenge.progress : _fill.value;
        return Opacity(
          opacity: 0.15 + 0.85 * enter,
          child: Transform.translate(
            offset: Offset(0, (1 - enter) * 28),
            child: _Card(
              challenge: widget.challenge,
              fill: fill,
              shown: widget.challenge.current.toDouble(),
              complete: widget.challenge.isComplete,
              rewardLabel: widget.rewardLabel,
            ),
          ),
        );
      },
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.challenge,
    required this.fill,
    required this.shown,
    required this.complete,
    this.rewardLabel,
  });

  final Challenge challenge;
  final double fill;
  final double shown;
  final bool complete;
  final String? rewardLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 60,
            child: CustomPaint(
              painter: challenge.kind == ChallengeKind.donut
                  ? DonutQuarterPainter(fill: fill, complete: complete)
                  : CoffeeArcPainter(fill: fill, complete: complete),
              child: Center(
                child: Text(
                  '${shown.round()}/${challenge.target}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.chocolate,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.chocolate,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                  child: LinearProgressIndicator(
                    value: challenge.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.hairline,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.seed,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _EarnButton(active: challenge.isComplete, label: rewardLabel),
        ],
      ),
    );
  }
}

class _EarnButton extends StatefulWidget {
  const _EarnButton({required this.active, this.label});

  final bool active;
  final String? label;

  @override
  State<_EarnButton> createState() => _EarnButtonState();
}

class _EarnButtonState extends State<_EarnButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startPulse();
  }

  void _startPulse() {
    if (!widget.active || MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0;
      return;
    }
    _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_EarnButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) {
      _startPulse();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.label ?? 'Earn';
    if (!widget.active) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.shimmerBase,
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.latte,
          ),
        ),
      );
    }
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final glow = 0.5 + 0.5 * math.sin(_pulse.value * math.pi);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            boxShadow: [
              BoxShadow(
                color: AppColors.seed.withValues(alpha: 0.18 + 0.22 * glow),
                blurRadius: 8 + 8 * glow,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Material(
            color: AppColors.seed,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            clipBehavior: Clip.antiAlias,
            child: InkResponse(
              radius: 26,
              onTap: () => _nudge(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _nudge(BuildContext context) {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${widget.label ?? 'Earn'} tapped')),
      );
  }
}

/// Fills a donut ring in quarters, one quarter per completed item.
class DonutQuarterPainter extends CustomPainter {
  const DonutQuarterPainter({required this.fill, required this.complete});

  final double fill;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.shimmerBase,
    );

    final quarters = (fill * 4).clamp(0.0, 4.0);
    final glaze = Paint()
      ..color = complete ? AppColors.mint : AppColors.seed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.butt;
    for (var i = 0; i < quarters.floor(); i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -math.pi / 2 + i * (math.pi / 2),
        math.pi / 2,
        false,
        glaze,
      );
    }
    final remainder = quarters - quarters.floor();
    if (remainder > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 4),
        -math.pi / 2 + quarters.floor() * (math.pi / 2),
        remainder * (math.pi / 2),
        false,
        glaze,
      );
    }

    if (complete) {
      canvas.drawCircle(
        center,
        radius * 0.34,
        Paint()..color = AppColors.mint,
      );
      final check = Path()
        ..moveTo(center.dx - radius * 0.16, center.dy)
        ..lineTo(center.dx - radius * 0.03, center.dy + radius * 0.13)
        ..lineTo(center.dx + radius * 0.18, center.dy - radius * 0.14);
      canvas.drawPath(
        check,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round,
      );
    } else {
      canvas.drawCircle(
        center,
        radius * 0.34,
        Paint()..color = AppColors.cream,
      );
    }
  }

  @override
  bool shouldRepaint(DonutQuarterPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.complete != complete;
}

/// Sweeps a coffee cup arc around the stamp count.
class CoffeeArcPainter extends CustomPainter {
  const CoffeeArcPainter({required this.fill, required this.complete});

  final double fill;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 3;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7,
    );
    if (fill <= 0) {
      return;
    }
    canvas.drawArc(
      rect,
      -math.pi / 2,
      fill.clamp(0.0, 1.0) * math.pi * 2,
      false,
      Paint()
        ..color = complete ? AppColors.mint : AppColors.caramel
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CoffeeArcPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.complete != complete;
}
