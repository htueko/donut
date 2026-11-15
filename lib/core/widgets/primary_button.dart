import 'package:flutter/material.dart';

import '../../app/motion/app_motion.dart';
import '../../app/theme/app_palette.dart';
import '../../app/theme/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.enabled = true,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool enabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final busy = loading;
    final active = enabled && !busy;
    return PressablePrimary(
      active: active,
      child: FilledButton(
        onPressed: active ? onPressed : null,
        child: AnimatedSwitcher(
          duration: motionScale(context, AppMotion.base),
          switchInCurve: AppMotion.standard,
          child: busy
              ? SizedBox.square(
                  dimension: AppSpacing.spinnerSize,
                  child: CircularProgressIndicator(
                    strokeWidth: AppSpacing.hairlineWidth,
                    color: context.palette.onPrimary,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[icon!, const SizedBox(width: 8)],
                    Flexible(
                      child: Text(label, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class PressablePrimary extends StatefulWidget {
  const PressablePrimary({
    required this.active,
    required this.child,
    super.key,
  });

  final bool active;
  final Widget child;

  @override
  State<PressablePrimary> createState() => _PressablePrimaryState();
}

class _PressablePrimaryState extends State<PressablePrimary> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.active || _pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? AppMotion.pressScale : 1,
        duration: motionScale(context, AppMotion.fast),
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
