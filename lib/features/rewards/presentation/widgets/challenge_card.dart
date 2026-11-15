import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../catalog/domain/catalog_enums.dart';
import '../../../catalog/domain/challenge.dart';
import 'challenge_painters.dart';

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
