import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/motion/app_motion.dart';
import '../../../../app/theme/app_colors.dart';

class RegistrationProgressRing extends StatefulWidget {
  const RegistrationProgressRing({
    required this.step,
    required this.total,
    super.key,
  });

  final int step;
  final int total;

  @override
  State<RegistrationProgressRing> createState() =>
      _RegistrationProgressRingState();
}

class _RegistrationProgressRingState extends State<RegistrationProgressRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.base,
  );
  late Animation<double> _sweep;

  bool get _complete => widget.step >= widget.total;

  @override
  void initState() {
    super.initState();
    _controller.value = 1;
    _buildSweep();
  }

  @override
  void didUpdateWidget(RegistrationProgressRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      _buildSweep();
      _controller.forward(from: 0);
    }
  }

  void _buildSweep() {
    _sweep =
        Tween<double>(
          begin: _fractionFor(widget.step - 1),
          end: _fractionFor(widget.step),
        ).animate(
          CurvedAnimation(parent: _controller, curve: AppMotion.emphasized),
        );
  }

  double _fractionFor(int step) {
    if (step <= 0) {
      return 0;
    }
    return (step / widget.total).clamp(0.0, 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return AnimatedSwitcher(
      duration: motionScale(context, AppMotion.base),
      switchInCurve: AppMotion.standard,
      child: _complete
          ? const _CheckBadge()
          : SizedBox.square(
              dimension: 40,
              child: AnimatedBuilder(
                animation: _sweep,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _RingPainter(
                      progress: reduceMotion
                          ? _fractionFor(widget.step)
                          : _sweep.value,
                    ),
                    child: Center(
                      child: Text(
                        '${widget.step}/${widget.total}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.chocolate,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 3.5;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      size.width - stroke,
      size.height - stroke,
    );
    final track = Paint()
      ..color = AppColors.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    final fill = Paint()
      ..color = AppColors.seed
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * progress, false, fill);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CheckBadge extends StatelessWidget {
  const _CheckBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: AppColors.mint,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 22),
    );
  }
}
