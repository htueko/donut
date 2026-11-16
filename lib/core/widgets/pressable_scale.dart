import 'package:flutter/material.dart';

import '../../app/motion/app_motion.dart';

class PressableScale extends StatefulWidget {
  const PressableScale({
    required this.child,
    this.onPressed,
    this.scale = AppMotion.pressScale,
    super.key,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
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
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: motionScale(context, AppMotion.fast),
        curve: AppMotion.standard,
        child: widget.child,
      ),
    );
  }
}
