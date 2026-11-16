import 'package:flutter/material.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/widgets/feedback_views.dart';

/// Two-tab switch whose pill slides between labels and whose list cross-fades.
class RewardTabs extends StatefulWidget {
  const RewardTabs({required this.labels, required this.builders, super.key});

  final List<String> labels;
  final List<WidgetBuilder> builders;

  @override
  State<RewardTabs> createState() => _RewardTabsState();
}

class _RewardTabsState extends State<RewardTabs>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );
  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.standard,
  );
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _controller.value = 1;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(int index) {
    if (index == _index || index < 0 || index >= widget.labels.length) {
      return;
    }
    setState(() => _index = index);
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
      return;
    }
    _controller
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PillBar(labels: widget.labels, selected: _index, onSelected: _select),
        const SizedBox(height: AppSpacing.lg),
        AnimatedSize(
          duration: motionScale(context, AppMotion.base),
          curve: AppMotion.standard,
          child: FadeTransition(
            opacity: _fade,
            child: KeyedSubtree(
              key: ValueKey<int>(_index),
              child: widget.builders[_index](context),
            ),
          ),
        ),
      ],
    );
  }
}

class _PillBar extends StatelessWidget {
  const _PillBar({
    required this.labels,
    required this.selected,
    required this.onSelected,
  });

  final List<String> labels;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth / labels.length;
        return Container(
          height: AppSpacing.tabBarHeight,
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            color: palette.shimmerBase,
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                alignment: _alignmentFor(selected),
                duration: motionScale(context, AppMotion.base),
                curve: AppMotion.emphasized,
                child: Container(
                  width: width - AppSpacing.sm,
                  decoration: BoxDecoration(
                    color: palette.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                    boxShadow: [
                      BoxShadow(
                        color: palette.shadow,
                        blurRadius: AppSpacing.tabShadowBlur,
                        offset: const Offset(0, AppSpacing.xxs),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < labels.length; i++)
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                        onTap: () => onSelected(i),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: motionScale(context, AppMotion.fast),
                            style: AppTypography.caption.copyWith(
                              fontWeight: i == selected
                                  ? AppTypography.h2Weight
                                  : AppTypography.subtitleWeight,
                              color: i == selected
                                  ? palette.textPrimary
                                  : palette.textSecondary,
                            ),
                            child: Text(
                              labels[i],
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Alignment _alignmentFor(int selected) {
    if (labels.length <= 1) {
      return Alignment.center;
    }
    return Alignment(-1 + (2 * selected) / (labels.length - 1), 0);
  }
}

/// Gift tab body: a short explainer plus a placeholder panel.
class GiftPanel extends StatelessWidget {
  const GiftPanel({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EmptyStateView(message: message, icon: Icons.card_giftcard_outlined),
      ],
    );
  }
}
