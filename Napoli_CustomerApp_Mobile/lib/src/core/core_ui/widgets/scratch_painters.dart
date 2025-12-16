import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import '../theme.dart';

class ScratchPainter extends CustomPainter {
  final List<Offset> scratchedPoints;
  final double strokeWidth;
  final double circleRadius;

  ScratchPainter(
    this.scratchedPoints, {
    this.strokeWidth = 45.0,
    this.circleRadius = 22.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.transparent
      ..blendMode = ui.BlendMode.clear
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;

    for (int i = 0; i < scratchedPoints.length - 1; i++) {
      final current = scratchedPoints[i];
      final next = scratchedPoints[i + 1];

      if (!current.isInfinite && !next.isInfinite) {
        // Dibujar línea
        canvas.drawLine(current, next, paint);
        // Dibujar círculo en cada punto para mejor cobertura
        canvas.drawCircle(current, circleRadius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(ScratchPainter oldDelegate) => true;
}

class TexturePainter extends CustomPainter {
  final double scale;
  final Color dotColor;

  TexturePainter(this.scale, this.dotColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = dotColor
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 1.5 * scale, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
