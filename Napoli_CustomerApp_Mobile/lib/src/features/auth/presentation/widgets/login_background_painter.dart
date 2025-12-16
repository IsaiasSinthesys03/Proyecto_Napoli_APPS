import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';

class LoginBackgroundPainter extends CustomPainter {
  final double t; // 0..1 animation value
  final ColorScheme colors;

  LoginBackgroundPainter(this.t, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Base gradient: from a slightly muted green to a soft beige to create a warm brand backdrop
    final rect = Rect.fromLTWH(0, 0, w, h);
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          colors.primary.withAlpha((0.92 * 255).round()),
          AppColors.accentBeigeLight.withAlpha((0.95 * 255).round()),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // Soft beige wave (lighter, blends into gradient)
    final wavePaint = Paint()
      ..color = AppColors.accentBeige.withAlpha(
        ((0.85 - 0.12 * t) * 255).round(),
      );
    final path = Path();
    path.moveTo(0, h * 0.55 + (t - 0.5) * 30);
    path.quadraticBezierTo(
      w * 0.25,
      h * 0.45 + (t - 0.5) * 40,
      w * 0.5,
      h * 0.58 + (t - 0.5) * 30,
    );
    path.quadraticBezierTo(
      w * 0.75,
      h * 0.70 + (t - 0.5) * 20,
      w,
      h * 0.62 + (t - 0.5) * 30,
    );
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();
    canvas.drawPath(path, wavePaint);

    // Floating decorative circles: use a subtle translucent white/beige to lift the composition
    final circlePaint = Paint()
      ..color = AppColors.white.withAlpha(((0.06 + 0.03 * t) * 255).round());
    final r = 20.0 + 8.0 * t;
    canvas.drawCircle(
      Offset(w * 0.14 + 40 * (t - 0.5), h * 0.16),
      r,
      circlePaint,
    );
    canvas.drawCircle(
      Offset(w * 0.82 - 50 * (t - 0.5), h * 0.24),
      r * 0.7,
      circlePaint,
    );

    // Warm accent overlay (soft) to the top-right for warm contrast
    final accentPaint = Paint()
      ..color = AppColors.fireOrange.withAlpha(
        ((0.06 + 0.04 * t) * 255).round(),
      );
    final terrPath = Path();
    terrPath.moveTo(w * 0.78, h * 0.02 + 10 * t);
    terrPath.quadraticBezierTo(w * 0.92, h * 0.12 + 20 * t, w * 0.72, h * 0.22);
    terrPath.quadraticBezierTo(w * 0.62, h * 0.12, w * 0.78, h * 0.02 + 10 * t);
    canvas.drawPath(terrPath, accentPaint);

    // Small accent blob using onSurface with low opacity to harmonize
    final blobPaint = Paint()
      ..color = colors.onSurface.withAlpha(
        ((0.04 + 0.03 * (1 - t)) * 255).round(),
      );
    final blob = Path();
    blob.moveTo(w * 0.75, h * 0.05 + 20 * t);
    blob.quadraticBezierTo(w * 0.82, h * 0.18, w * 0.65, h * 0.22);
    blob.quadraticBezierTo(w * 0.55, h * 0.12, w * 0.75, h * 0.05 + 20 * t);
    canvas.drawPath(blob, blobPaint);
  }

  @override
  bool shouldRepaint(covariant LoginBackgroundPainter old) =>
      old.t != t || old.colors != colors;
}
