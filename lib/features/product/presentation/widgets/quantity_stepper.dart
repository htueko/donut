import 'package:flutter/material.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';

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
          width: 44,
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF43302B),
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
    return Material(
      color: enabled ? AppColors.cream : AppColors.shimmerBase,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkResponse(
        radius: 26,
        onTap: onPressed,
        child: SizedBox.square(
          dimension: 40,
          child: Icon(
            icon,
            size: 20,
            color: enabled ? AppColors.cocoa : AppColors.latte,
          ),
        ),
      ),
    );
  }
}
