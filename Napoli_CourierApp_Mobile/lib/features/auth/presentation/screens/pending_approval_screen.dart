import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/driver.dart';

/// Pantalla de espera para repartidores pendientes de aprobación
class PendingApprovalScreen extends StatelessWidget {
  final Driver driver;

  const PendingApprovalScreen({required this.driver, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono animado de reloj
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Icon(
                      Icons.access_time,
                      size: 80,
                      color: theme.colorScheme.primary.withValues(alpha: 0.7),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.spacingXL),

              // Título
              Text(
                'Solicitud en Revisión',
                style: AppTextStyles.h2.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingL),

              // Mensaje
              Text(
                'Tu solicitud de registro está siendo revisada por el equipo de Napoli.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingM),
              Text(
                'Te notificaremos por correo cuando sea aprobada.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.spacingXL),

              // Card con datos enviados
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusMedium,
                  ),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datos Enviados:',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingM),
                    _buildInfoRow(context, Icons.person, driver.name),
                    const SizedBox(height: AppDimensions.spacingS),
                    _buildInfoRow(context, Icons.email, driver.email),
                    const SizedBox(height: AppDimensions.spacingS),
                    _buildInfoRow(
                      context,
                      Icons.directions_car,
                      '${driver.vehicleType.displayName} - ${driver.licensePlate}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXL),

              // Botón cerrar sesión
              AppButton(
                label: 'Cerrar Sesión',
                icon: Icons.logout,
                type: AppButtonType.outlined,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) =>
                          const Scaffold(body: Center(child: Text('Login'))),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: AppDimensions.iconMedium,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
