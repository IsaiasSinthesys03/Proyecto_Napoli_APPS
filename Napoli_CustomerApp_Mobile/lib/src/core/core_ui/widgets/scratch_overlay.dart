import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ScratchOverlay extends StatelessWidget {
  final bool isScratching;
  final bool isRevealed;
  final double scratchProgress;
  final double scale;
  final double cardWidth;

  const ScratchOverlay({
    super.key,
    required this.isScratching,
    required this.isRevealed,
    required this.scratchProgress,
    required this.scale,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: isScratching ? 1.2 : 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, animScale, child) {
                return Transform.scale(scale: animScale, child: child);
              },
              child: Container(
                width: 96 * scale,
                height: 96 * scale,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onPrimary.withValues(alpha: 0.06),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.12),
                      blurRadius: 8 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: Center(
                  child: Lottie.asset(
                    'assets/animation/scratch.json',
                    width: 72 * scale,
                    height: 72 * scale,
                    fit: BoxFit.contain,
                    repeat: true,
                    animate: !isRevealed,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16 * scale),
            Text(
              '¡Rasca aquí!',
              style: TextStyle(
                fontSize: 22 * scale,
                fontWeight: FontWeight.bold,
                color: onPrimary.withValues(alpha: 0.95),
                letterSpacing: 1.5 * scale,
                shadows: [
                  Shadow(
                    color: theme.shadowColor.withValues(alpha: 0.5),
                    offset: Offset(2 * scale, 2 * scale),
                    blurRadius: 4 * scale,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'Descubre tu premio',
              style: TextStyle(
                fontSize: 15 * scale,
                color: onPrimary.withValues(alpha: 0.8),
                letterSpacing: 0.8 * scale,
              ),
            ),
            SizedBox(height: 24 * scale),
            // Barra de progreso
            Container(
              width: cardWidth * 0.72,
              height: 10 * scale,
              decoration: BoxDecoration(
                color: onPrimary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(5 * scale),
                border: Border.all(
                  color: onPrimary.withValues(alpha: 0.5),
                  width: 1 * scale,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5 * scale),
                child: LinearProgressIndicator(
                  value: scratchProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    onPrimary.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              '${(scratchProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.bold,
                color: onPrimary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
