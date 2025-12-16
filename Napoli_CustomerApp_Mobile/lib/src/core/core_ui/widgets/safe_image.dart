import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget seguro para cargar imágenes con fallback automático
/// Supports both network URLs and local assets
class SafeImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SafeImage({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  /// Check if the path is a network URL
  bool get isNetworkImage =>
      assetPath.startsWith('http://') || assetPath.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (isNetworkImage) {
      return Image.network(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(context);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildFallbackPlaceholder(context);
        },
      );
    }

    // Local asset
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildFallbackPlaceholder(context);
      },
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildFallbackPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withAlpha((0.12 * 255).round()),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableH =
              constraints.hasBoundedHeight && constraints.maxHeight > 0
              ? constraints.maxHeight
              : (height ?? 64.0);
          final iconSize = math.min(48.0, math.max(12.0, availableH * 0.55));
          final gap = math.max(4.0, availableH * 0.06);
          final fontSize = math.min(12.0, math.max(10.0, availableH * 0.18));
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.local_pizza,
                size: iconSize,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withAlpha((0.5 * 255).round()),
              ),
              SizedBox(height: gap),
              Text(
                'Pizza',
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                  fontSize: fontSize,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
