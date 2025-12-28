import 'package:flutter/material.dart';

/// Placeholder screen for features under development
class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const PlaceholderScreen({
    required this.title,
    required this.icon,
    this.message = 'Esta función estará disponible próximamente',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '🚧 En construcción 🚧',
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
