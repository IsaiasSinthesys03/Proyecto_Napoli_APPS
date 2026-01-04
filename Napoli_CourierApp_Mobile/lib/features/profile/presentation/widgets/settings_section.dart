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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          child: Text('Configuración', style: AppTextStyles.h3),
        ),
        Card(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notificaciones
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Notificaciones Push',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Recibir alertas de nuevos pedidos',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: profile.notificationsEnabled,
                      onChanged: onNotificationsChanged,
                      activeColor: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ),

              // Idioma
              _buildSettingItem(
                icon: Icons.language_outlined,
                title: 'Idioma',
                subtitle: 'Español',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Próximamente: Selector de idioma'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),

              // Cambiar contraseña
              _buildSettingItem(
                icon: Icons.lock_outline,
                title: 'Cambiar Contraseña',
                onTap: onChangePasswordPressed,
              ),

              // Versión de la app
              _buildSettingItem(
                icon: Icons.info_outline,
                title: 'Versión de la App',
                subtitle: profile.appVersion,
                onTap: () {},
              ),

              // Términos y privacidad
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: 'Términos y Privacidad',
                onTap: () {
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
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryGreen),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Column(
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (subtitle == null) const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
