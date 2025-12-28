import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../domain/entities/driver_profile.dart';

/// Widget que muestra la información del conductor en una tarjeta
class ProfileInfoCard extends StatelessWidget {
  final DriverProfile profile;

  const ProfileInfoCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final driver = profile.driver;
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Información Personal', style: AppTextStyles.h3),
            const SizedBox(height: AppDimensions.spacingM),

            _buildInfoRow(
              icon: Icons.email_outlined,
              label: 'Email',
              value: driver.email,
              theme: theme,
            ),
            const Divider(height: AppDimensions.spacingL),

            _buildInfoRow(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: driver.phone,
              theme: theme,
            ),
            const Divider(height: AppDimensions.spacingL),

            _buildInfoRow(
              icon: Icons.directions_car_outlined,
              label: 'Vehículo',
              value: driver.vehicleType.displayName,
              theme: theme,
            ),
            const Divider(height: AppDimensions.spacingL),

            _buildInfoRow(
              icon: Icons.pin_outlined,
              label: 'Placa',
              value: driver.licensePlate,
              theme: theme,
            ),
            const Divider(height: AppDimensions.spacingL),

            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Miembro desde',
              value: DateFormat('dd/MM/yyyy').format(driver.createdAt),
              theme: theme,
            ),
            const Divider(height: AppDimensions.spacingL),

            _buildInfoRow(
              icon: Icons.verified_outlined,
              label: 'Estado',
              value: driver.status.displayName,
              theme: theme,
              valueColor: _getStatusColor(driver.status.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primaryGreen),
        const SizedBox(width: AppDimensions.spacingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.successGreen;
      case 'pending':
        return AppColors.warningOrange;
      case 'inactive':
        return AppColors.errorRed;
      default:
        return AppColors.textDark;
    }
  }
}
