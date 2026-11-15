import 'package:flutter/widgets.dart';

class AppMotion {
  const AppMotion._();

  static const Duration instant = Duration.zero;
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 280);
  static const Duration slow = Duration(milliseconds: 450);
  static const Duration emphasis = Duration(milliseconds: 650);
  static const Duration ambient = Duration(seconds: 4);
  static const Duration shimmer = Duration(milliseconds: 1400);
  static const Duration attention = Duration(milliseconds: 1100);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve decelerate = Curves.easeOut;
  static const Curve accelerate = Curves.easeIn;
  static const Curve emphasized = Cubic(0.2, 0, 0, 1);
  static const Curve overshoot = Cubic(0.34, 1.56, 0.64, 1);

  static const double pressScale = 0.96;
}

Duration motionScale(BuildContext context, Duration duration) {
  if (MediaQuery.disableAnimationsOf(context)) {
    return AppMotion.instant;
  }
  return duration;
}

/// Fraction a controller has reached, or [fallback] when animations are off.
double motionValue(
  Animation<double> animation,
  BuildContext context, {
  double fallback = 1,
}) {
  if (MediaQuery.disableAnimationsOf(context)) {
    return fallback;
  }
  return animation.value;
}

/// Drives a repeating [period] controller, but leaves it parked at the end when
/// the user asks for reduced motion.
void animateRepeat(
  AnimationController controller,
  BuildContext context, {
  required Duration period,
}) {
  if (MediaQuery.disableAnimationsOf(context)) {
    controller.value = 1;
    return;
  }
  controller.repeat(period: period);
}

/// Plays [controller] once from zero, jumping straight to the end when the user
/// asks for reduced motion.
void animateOnce(AnimationController controller, BuildContext context) {
  if (MediaQuery.disableAnimationsOf(context)) {
    controller.value = 1;
    return;
  }
  controller.forward(from: 0);
}
