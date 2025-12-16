import 'package:flutter/material.dart';

// Painter para el patrón de fondo de la tarjeta
class CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Círculos decorativos
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 30, paint);

    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.7), 20, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
