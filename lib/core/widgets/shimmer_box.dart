import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/motion/app_motion.dart';
import '../../app/theme/app_colors.dart';

class ShimmerBox extends StatefulWidget {
  const ShimmerBox({
    this.width = double.infinity,
    this.height = 16,
    this.radius = 8,
    super.key,
  });

  final double width;
  final double height;
  final double radius;

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.shimmer,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return _box();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = math.sin(_controller.value * math.pi * 2) * 0.5 + 0.5;
        return _box(gradient: _gradient(t));
      },
    );
  }

  Widget _box({Gradient? gradient}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.shimmerBase,
        borderRadius: BorderRadius.circular(widget.radius),
        gradient: gradient,
      ),
      child: SizedBox(width: widget.width, height: widget.height),
    );
  }

  Gradient _gradient(double t) {
    final shift = (t - 0.5) * 1.4;
    return LinearGradient(
      colors: const [
        AppColors.shimmerBase,
        AppColors.shimmerHighlight,
        AppColors.shimmerBase,
      ],
      stops: [
        (0.35 + shift).clamp(0.0, 1.0),
        (0.5 + shift).clamp(0.0, 1.0),
        (0.65 + shift).clamp(0.0, 1.0),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      tileMode: TileMode.clamp,
    );
  }
}
