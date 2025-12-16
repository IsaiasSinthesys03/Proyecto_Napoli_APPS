import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';

class PhotoOptionsBottomSheet extends StatelessWidget {
  final Function(String) onPhotoSelected;

  const PhotoOptionsBottomSheet({super.key, required this.onPhotoSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Icon(Icons.photo_camera, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                l10n.changeProfilePhoto,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Opciones de cámara y galería
          _buildOptionTile(
            context,
            theme,
            icon: Icons.camera_alt,
            title: l10n.takePhoto,
            subtitle: l10n.takePhotoSubtitle,
            onTap: () => _simulatePhotoCapture(context, l10n),
          ),
          _buildOptionTile(
            context,
            theme,
            icon: Icons.photo_library,
            title: l10n.chooseGallery,
            subtitle: l10n.chooseGallerySubtitle,
            onTap: () => _simulateGallerySelection(context, l10n),
          ),

          // Opción para quitar foto actual (si existe)
          _buildOptionTile(
            context,
            theme,
            icon: Icons.person_outline,
            title: l10n.useInitials,
            subtitle: l10n.useInitialsSubtitle,
            onTap: () => _removePhoto(context, l10n),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 24),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
      ),
      onTap: onTap,
    );
  }

  void _simulatePhotoCapture(BuildContext context, AppLocalizations l10n) {
    // Simular captura de foto con éxito
    onPhotoSelected('camera_photo_${DateTime.now().millisecondsSinceEpoch}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.photoCaptured),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _simulateGallerySelection(BuildContext context, AppLocalizations l10n) {
    // Simular selección de galería con éxito
    onPhotoSelected('gallery_photo_${DateTime.now().millisecondsSinceEpoch}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.photoSelected),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _removePhoto(BuildContext context, AppLocalizations l10n) {
    // Quitar foto actual y volver a iniciales
    onPhotoSelected('');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.person, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.usingInitials),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
