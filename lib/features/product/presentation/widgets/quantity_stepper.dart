import 'package:flutter/material.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_palette.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.quantity,
    required this.onChanged,
    this.min = 1,
    super.key,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final int min;

  void _change(int delta) {
    final next = quantity + delta;
    if (next < min || next == quantity) {
      return;
    }
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepButton(
          icon: Icons.remove,
          onPressed: quantity > min ? () => _change(-1) : null,
        ),
        SizedBox(
          width: AppSpacing.stepperWidth,
          child: AnimatedSwitcher(
            duration: motionScale(context, AppMotion.fast),
            transitionBuilder: (child, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.4),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: Text(
              '$quantity',
              key: ValueKey<int>(quantity),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: AppSpacing.stepperFontSize,
                fontWeight: AppTypography.h2Weight,
                color: context.palette.textPrimary,
              ),
            ),
          ),
        ),
        _StepButton(icon: Icons.add, onPressed: () => _change(1)),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final palette = context.palette;
    return Material(
      color: enabled ? palette.background : palette.shimmerBase,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkResponse(
        radius: AppSpacing.stepButtonSize / 2,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: AppSpacing.stepButtonSize,
          child: Icon(
            icon,
            size: AppSpacing.iconSm,
            color: enabled ? palette.textPrimary : palette.textMuted,
          ),
        ),
      ),
    );
  }
}
