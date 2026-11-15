import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Fills a donut ring in quarters, one quarter per completed item.
class DonutQuarterPainter extends CustomPainter {
  const DonutQuarterPainter({
    required this.fill,
    required this.complete,
    required this.track,
    required this.progress,
    required this.success,
    required this.center,
    required this.onProgress,
  });

  static const double _stroke = 8;
  static const double _inset = 3;

  final double fill;
  final bool complete;
  final Color track;
  final Color progress;
  final Color success;
  final Color center;
  final Color onProgress;

  @override
  void paint(Canvas canvas, Size size) {
    final middle = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - _inset;
    canvas.drawCircle(middle, radius, Paint()..color = track);

    final quarters = fill.clamp(0.0, 1.0) * 4;
    final glaze = Paint()
      ..color = complete ? success : progress
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.butt;

    final rect = Rect.fromCircle(center: middle, radius: radius - _stroke / 2);
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
      _paintComplete(canvas, middle, radius);
    } else {
      canvas.drawCircle(
        middle,
        radius * _centerHoleRatio,
        Paint()..color = center,
      );
    }
  }

  static const double _centerHoleRatio = 0.34;

  double _startAngle(int quarter) => -math.pi / 2 + quarter * (math.pi / 2);

  void _paintComplete(Canvas canvas, Offset middle, double radius) {
    canvas.drawCircle(
      middle,
      radius * _centerHoleRatio,
      Paint()..color = success,
    );
    final check = Path()
      ..moveTo(middle.dx - radius * 0.16, middle.dy)
      ..lineTo(middle.dx - radius * 0.03, middle.dy + radius * 0.13)
      ..lineTo(middle.dx + radius * 0.18, middle.dy - radius * 0.14);
    canvas.drawPath(
      check,
      Paint()
        ..color = onProgress
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(DonutQuarterPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.complete != complete ||
      oldDelegate.track != track ||
      oldDelegate.progress != progress ||
      oldDelegate.success != success ||
      oldDelegate.center != center ||
      oldDelegate.onProgress != onProgress;
}

/// Sweeps a coffee cup arc around the stamp count.
class CoffeeArcPainter extends CustomPainter {
  const CoffeeArcPainter({
    required this.fill,
    required this.complete,
    required this.track,
    required this.progress,
    required this.success,
  });

  static const double _stroke = 7;
  static const double _inset = 3;

  final double fill;
  final bool complete;
  final Color track;
  final Color progress;
  final Color success;

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
        ..color = track
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
        ..color = complete ? success : progress
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(CoffeeArcPainter oldDelegate) =>
      oldDelegate.fill != fill ||
      oldDelegate.complete != complete ||
      oldDelegate.track != track ||
      oldDelegate.progress != progress ||
      oldDelegate.success != success;
}
