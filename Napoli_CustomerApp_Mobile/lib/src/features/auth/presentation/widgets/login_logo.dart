import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'dart:math' as math;

class LoginLogo extends StatelessWidget {
  final Animation<double> animation;

  const LoginLogo({super.key, required this.animation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final dy = (0.5 - animation.value) * 8; // slightly larger float
        final angle =
            math.sin(animation.value * math.pi * 2) * 0.04; // small rotation
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(angle: angle, child: child),
        );
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.secondary.withValues(alpha: 0.25),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
          border: Border.all(
            color: AppColors.primaryRed.withValues(alpha: 0.6),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Image.asset(
            'assets/images/logo_fondo_blanco-transpa.png',
            fit: BoxFit.contain,
            width: 56,
            height: 56,
          ),
        ),
      ),
    );
  }
}
