import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/driver_profile.dart';

/// Widget que muestra la sección de configuración
class SettingsSection extends StatelessWidget {
  final DriverProfile profile;
  final Function(bool) onNotificationsChanged;
  final VoidCallback onChangePasswordPressed;

  const SettingsSection({
    super.key,
    required this.profile,
    required this.onNotificationsChanged,
    required this.onChangePasswordPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Text('Configuración', style: AppTextStyles.h3),
          ),
          const Divider(height: 1),

          // Notificaciones
          SwitchListTile(
            secondary: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryGreen,
            ),
            title: const Text('Notificaciones Push'),
            subtitle: const Text('Recibir alertas de nuevos pedidos'),
            value: profile.notificationsEnabled,
            onChanged: onNotificationsChanged,
            activeColor: AppColors.primaryGreen,
          ),
          const Divider(height: 1),

          // Idioma
          ListTile(
            leading: const Icon(
              Icons.language_outlined,
              color: AppColors.primaryGreen,
            ),
            title: const Text('Idioma'),
            subtitle: const Text('Español'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Implementar selector de idioma
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Selector de idioma'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),

          // Cambiar contraseña
          ListTile(
            leading: const Icon(
              Icons.lock_outline,
              color: AppColors.primaryGreen,
            ),
            title: const Text('Cambiar Contraseña'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onChangePasswordPressed,
          ),
          const Divider(height: 1),

          // Versión de la app
          ListTile(
            leading: const Icon(
              Icons.info_outline,
              color: AppColors.primaryGreen,
            ),
            title: const Text('Versión de la App'),
            subtitle: Text(profile.appVersion),
          ),
          const Divider(height: 1),

          // Términos y privacidad
          ListTile(
            leading: const Icon(
              Icons.description_outlined,
              color: AppColors.primaryGreen,
            ),
            title: const Text('Términos y Privacidad'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: Mostrar términos y condiciones
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Próximamente: Términos y Privacidad'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
