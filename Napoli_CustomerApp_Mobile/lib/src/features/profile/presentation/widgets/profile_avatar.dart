import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';

class ProfileAvatar extends StatelessWidget {
  final String? selectedImagePath;
  final VoidCallback onChangePhoto;

  const ProfileAvatar({
    super.key,
    required this.selectedImagePath,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: theme.colorScheme.primary,
              child: _buildAvatarContent(theme, l10n),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.surface,
                    width: 2,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: onChangePhoto,
          icon: Icon(Icons.edit, size: 18, color: theme.colorScheme.primary),
          label: Text(
            l10n.changePhoto,
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarContent(ThemeData theme, AppLocalizations l10n) {
    // Si hay una imagen seleccionada, mostrar simulación
    if (selectedImagePath != null && selectedImagePath!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.primary.withValues(alpha: 0.8),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person, size: 32, color: theme.colorScheme.onPrimary),
              Text(
                l10n.photo,
                style: TextStyle(
                  fontSize: 8,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Por defecto mostrar iniciales
    return Text(
      'JP', // Iniciales por defecto
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onPrimary,
      ),
    );
  }
}
