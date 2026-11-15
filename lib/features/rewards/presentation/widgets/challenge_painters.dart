import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';

/// Fills a donut ring in quarters, one quarter per completed item.
class DonutQuarterPainter extends CustomPainter {
  const DonutQuarterPainter({required this.fill, required this.complete});

  static const double _stroke = 8;
  static const double _inset = 3;

  final double fill;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _inset;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = AppColors.shimmerBase,
    );

    final quarters = fill.clamp(0.0, 1.0) * 4;
    final glaze = Paint()
      ..color = complete ? AppColors.mint : AppColors.seed
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: center, radius: radius - _stroke / 2);
    for (var i = 0; i < quarters.floor(); i++) {
      canvas.drawArc(rect, _startAngle(i), math.pi / 2, false, glaze);
    }
    final remainder = quarters - quarters.floor();
    if (remainder > 0) {
      canvas.drawArc(
        rect,
        _startAngle(quarters.floor()),
        remainder * (math.pi / 2),
        false,
        glaze,
      );
    }

    if (complete) {
      _paintComplete(canvas, center, radius);
    } else {
      canvas.drawCircle(
        center,
        radius * 0.34,
        Paint()..color = AppColors.cream,
      );
    }
  }

  double _startAngle(int quarter) => -math.pi / 2 + quarter * (math.pi / 2);

  void _paintComplete(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(center, radius * 0.34, Paint()..color = AppColors.mint);
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
  }

  @override
  bool shouldRepaint(DonutQuarterPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.complete != complete;
}

/// Sweeps a coffee cup arc around the stamp count.
class CoffeeArcPainter extends CustomPainter {
  const CoffeeArcPainter({required this.fill, required this.complete});

  static const double _stroke = 7;
  static const double _inset = 3;

  final double fill;
  final bool complete;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _inset;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = AppColors.hairline
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
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
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CoffeeArcPainter oldDelegate) =>
      oldDelegate.fill != fill || oldDelegate.complete != complete;
}
