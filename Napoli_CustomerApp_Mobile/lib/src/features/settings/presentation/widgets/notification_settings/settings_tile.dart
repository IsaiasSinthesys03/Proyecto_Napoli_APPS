import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget trailing;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = onTap != null;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isEnabled
              ? theme.colorScheme.primary.withAlpha((0.1 * 255).round())
              : theme.colorScheme.onSurface.withAlpha((0.05 * 255).round()),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withAlpha((0.3 * 255).round()),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isEnabled
              ? theme.colorScheme.onSurface
              : theme.colorScheme.onSurface.withAlpha((0.5 * 255).round()),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isEnabled
              ? theme.colorScheme.onSurface.withAlpha((0.7 * 255).round())
              : theme.colorScheme.onSurface.withAlpha((0.4 * 255).round()),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
