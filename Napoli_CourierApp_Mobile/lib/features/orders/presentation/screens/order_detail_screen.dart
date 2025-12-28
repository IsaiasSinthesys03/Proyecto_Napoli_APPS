import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../../core/services/phone_service.dart';
import '../../../../core/services/navigation_service.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../cubit/orders_cubit.dart';
import '../cubit/orders_state.dart';
import '../widgets/customer_info_card.dart';
import '../widgets/delivery_address_card.dart';
import 'package:go_router/go_router.dart';
import '../../../dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../../profile/presentation/cubit/profile_cubit.dart';
import '../../../../core/di/injection.dart';
import '../widgets/order_items_list.dart';

/// Pantalla de detalle de pedido
class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  final String driverId;
  final Order? order; // Order opcional para navegación desde historial
  final PhoneService phoneService;
  final NavigationService navigationService;

  const OrderDetailScreen({
    required this.orderId,
    required this.driverId,
    this.order, // Opcional
    required this.phoneService,
    required this.navigationService,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Si ya tenemos el order (navegación desde historial), mostrarlo directamente
    if (order != null) {
      // Ocultar acciones de contacto si el pedido está entregado (privacidad)
      final hideContactActions = order!.status == OrderStatus.delivered;
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle del Pedido')),
        body: _buildOrderDetail(
          context,
          order!,
          hideContactActions: hideContactActions,
        ),
      );
    }

    // Si no, usar OrdersCubit para cargarlo (navegación desde dashboard)
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Pedido')),
      body: BlocConsumer<OrdersCubit, OrdersState>(
        listener: (context, state) {
          if (state is OrdersError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: theme.colorScheme.error,
              ),
            );
          } else if (state is OrderDetailLoaded) {
            if (state.order.status == OrderStatus.delivered) {
              // Refrescar toda la app
              print('🟢 Order delivered, refreshing app state...');
              getIt<DashboardCubit>().reloadDriver();
              getIt<ProfileCubit>().reloadProfile();

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Pedido entregado exitosamente'),
                  backgroundColor: AppColors.successGreen,
                ),
              );

              // Volver al dashboard
              if (context.canPop()) {
                context.pop();
              }
            }
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const LoadingIndicator();
          }

          if (state is OrderDetailLoaded || state is OrderUpdating) {
            final order = state is OrderDetailLoaded
                ? state.order
                : (state as OrderUpdating).order;

            final isUpdating = state is OrderUpdating;

            return Column(
              children: [
                // Contenido scrolleable
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppDimensions.spacingL),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Número de pedido y estado
                        _buildHeader(context, order),
                        const SizedBox(height: AppDimensions.spacingL),

                        // Info del cliente
                        CustomerInfoCard(
                          name: order.customerName,
                          phone: order.customerPhone,
                          onCallPressed: () async {
                            print(
                              '🟢 Call button pressed for: ${order.customerPhone}',
                            );
                            await phoneService.call(order.customerPhone);
                          },
                        ),
                        const SizedBox(height: AppDimensions.spacingL),

                        // Dirección de entrega
                        DeliveryAddressCard(
                          address: order.deliveryAddress,
                          onNavigatePressed: () async {
                            print('🟢 Navigate button pressed');
                            print(
                              '🟢 Address: ${order.deliveryAddress.street}',
                            );
                            await navigationService.openMaps(
                              latitude: order.deliveryAddress.latitude,
                              longitude: order.deliveryAddress.longitude,
                              label: order.deliveryAddress.street,
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.spacingL),

                        // Items del pedido
                        OrderItemsList(items: order.items),
                        const SizedBox(height: AppDimensions.spacingL),

                        // Resumen de pago
                        _buildPaymentSummary(context, order),
                      ],
                    ),
                  ),
                ),

                // Botón de acción (fijo abajo)
                if (order.status != OrderStatus.delivered &&
                    order.status != OrderStatus.cancelled)
                  _buildActionButton(context, order, isUpdating),
              ],
            );
          }

          return const Center(child: Text('No se pudo cargar el pedido'));
        },
      ),
    );
  }

  /// Construye el detalle del pedido (reutilizable para historial y dashboard)
  Widget _buildOrderDetail(
    BuildContext context,
    Order order, {
    bool isUpdating = false,
    bool hideContactActions =
        false, // Ocultar botones de contacto para privacidad
  }) {
    return Column(
      children: [
        // Contenido scrolleable
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Número de pedido y estado
                _buildHeader(context, order),
                const SizedBox(height: AppDimensions.spacingL),

                // Info del cliente (sin botón de llamar si está oculto)
                CustomerInfoCard(
                  name: order.customerName,
                  phone: order.customerPhone,
                  onCallPressed: hideContactActions
                      ? null // Ocultar botón de llamar
                      : () {
                          phoneService.call(order.customerPhone);
                        },
                ),
                const SizedBox(height: AppDimensions.spacingL),

                // Dirección de entrega (oculta completamente para pedidos entregados)
                if (!hideContactActions)
                  DeliveryAddressCard(
                    address: order.deliveryAddress,
                    onNavigatePressed: () {
                      navigationService.openMaps(
                        latitude: order.deliveryAddress.latitude,
                        longitude: order.deliveryAddress.longitude,
                        label: order.deliveryAddress.street,
                      );
                    },
                  ),
                if (!hideContactActions)
                  const SizedBox(height: AppDimensions.spacingL),

                // Items del pedido
                OrderItemsList(items: order.items),
                const SizedBox(height: AppDimensions.spacingL),

                // Resumen de pago
                _buildPaymentSummary(context, order),
              ],
            ),
          ),
        ),

        // Botón de acción (fijo abajo) - solo si no está entregado/cancelado
        if (order.status != OrderStatus.delivered &&
            order.status != OrderStatus.cancelled)
          _buildActionButton(context, order, isUpdating),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        children: [
          Text(
            order.orderNumber,
            style: AppTextStyles.h2.copyWith(color: theme.colorScheme.primary),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Text(
              order.status.displayName.toUpperCase(),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip(context, Icons.route, '${order.distanceKm} km'),
              _buildInfoChip(
                context,
                Icons.attach_money,
                '\$${order.driverEarnings.toStringAsFixed(0)}',
              ),
              _buildInfoChip(
                context,
                Icons.shopping_bag,
                '${order.totalItems} items',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(BuildContext context, order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen',
            style: AppTextStyles.h4.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          _buildPaymentRow('Subtotal', order.subtotal, theme),
          _buildPaymentRow('Envío', order.deliveryFee, theme),
          const Divider(),
          _buildPaymentRow('Total', order.total, theme, isBold: true),
          const SizedBox(height: AppDimensions.spacingS),
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: AppColors.successGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tu ganancia',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${order.driverEarnings.toStringAsFixed(0)}',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.successGreen,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    String label,
    double amount,
    ThemeData theme, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(0)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, order, bool isUpdating) {
    final buttonLabel = order.status.actionButtonLabel;
    if (buttonLabel.isEmpty) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingL),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: AppButton(
        label: buttonLabel,
        icon: _getActionIcon(order.status),
        isLoading: isUpdating,
        onPressed: () => _handleAction(context, order),
      ),
    );
  }

  IconData _getActionIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.available:
        return Icons.check_circle;
      case OrderStatus.accepted:
        return Icons.shopping_bag;
      case OrderStatus.pickedUp:
        return Icons.delivery_dining;
      case OrderStatus.onTheWay:
        return Icons.done_all;
      default:
        return Icons.check;
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.available:
        return AppColors.navigationBlue;
      case OrderStatus.accepted:
        return AppColors.warningOrange;
      case OrderStatus.pickedUp:
      case OrderStatus.onTheWay:
        return AppColors.primaryGreen;
      case OrderStatus.delivered:
        return AppColors.successGreen;
      case OrderStatus.cancelled:
        return AppColors.errorRed;
    }
  }

  void _handleAction(BuildContext context, order) {
    final cubit = context.read<OrdersCubit>();

    switch (order.status) {
      case OrderStatus.available:
        cubit.acceptOrder(orderId, driverId);
        break;
      case OrderStatus.accepted:
        cubit.confirmPickup(orderId, driverId);
        break;
      case OrderStatus.pickedUp:
      case OrderStatus.onTheWay:
        cubit.markDelivered(orderId, driverId);
        break;
      default:
        break;
    }
  }
}
