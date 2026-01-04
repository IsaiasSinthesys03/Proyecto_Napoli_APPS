import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/navigation/routes.dart';
import '../../domain/entities/order.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../dashboard/presentation/cubit/dashboard_state.dart';

class OrderCard extends StatelessWidget {
  final Order order;
  final bool isActive;

  const OrderCard({required this.order, this.isActive = false, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Obtener el driverId del DashboardCubit para pasarlo en la navegación
          final dashboardCubit = context.read<DashboardCubit>();
          String? driverId;
          if (dashboardCubit.state is DashboardLoaded) {
            driverId = (dashboardCubit.state as DashboardLoaded).driver.id;
          }

          context.push(
            AppRoutes.orderDetailPath(order.id, driverId: driverId),
            extra: order,
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: ID y Ganancia
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '#${order.orderNumber}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '\$${order.driverEarnings.toStringAsFixed(2)}',
                    style: AppTextStyles.h3.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Items count centered and red
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_bag_outlined,
                      size: 16,
                      color: AppColors.primaryRed,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${order.totalItems} items',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.spacingM),

              // Ruta Visual
              _buildRouteStep(
                context,
                icon: Icons.store,
                title: 'Barrio Napoli',
                subtitle: 'Recoger pedido',
                isStart: true,
              ),
              _buildConnector(),
              _buildRouteStep(
                context,
                icon: Icons.location_on,
                title: order.customerName,
                subtitle: order.deliveryAddress.street,
                isEnd: true,
              ),

              const SizedBox(height: AppDimensions.spacingM),
              const Divider(),

              // Footer: Distancia y Acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Hace 5 min', // Esto debería ser dinámico
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.directions_bike,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '2.5 km', // Esto debería venir de la orden
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  if (!isActive)
                    Text(
                      'VER DETALLES >',
                      style: AppTextStyles.buttonSmall.copyWith(
                        color: AppColors.primaryRed,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteStep(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    bool isStart = false,
    bool isEnd = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isStart ? AppColors.accentBeige : AppColors.inputFillLight,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: isStart ? AppColors.earthBrownDark : AppColors.primaryRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector() {
    return Container(
      margin: const EdgeInsets.only(
        left: 18,
      ), // Alineado con el centro del icono
      height: 20,
      width: 2,
      color: AppColors.dividerLight,
    );
  }
}
