import 'package:flutter/material.dart';
// theme not required here; this widget uses Theme.of(context)

class OrderStepper extends StatelessWidget {
  final int currentStep;

  const OrderStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildStep(
            context: context,
            theme: theme,
            stepNumber: 0,
            title: 'Pedido Confirmado',
            subtitle: 'Hemos recibido tu pedido',
            icon: Icons.check_circle,
          ),
          _buildConnector(context, 0),
          _buildStep(
            context: context,
            theme: theme,
            stepNumber: 1,
            title: 'En Preparación',
            subtitle: 'Tu comida se está preparando con amor',
            icon: Icons.restaurant_menu,
          ),
          _buildConnector(context, 1),
          _buildStep(
            context: context,
            theme: theme,
            stepNumber: 2,
            title: 'Repartidor en Camino',
            subtitle: '¡Tu pedido ya va hacia ti!',
            icon: Icons.delivery_dining,
          ),
          _buildConnector(context, 2),
          _buildStep(
            context: context,
            theme: theme,
            stepNumber: 3,
            title: 'Entregado',
            subtitle: '¡Disfruta tu comida!',
            icon: Icons.home,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required BuildContext context,
    required ThemeData theme,
    required int stepNumber,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isCompleted = stepNumber <= currentStep;
    final isCurrent = stepNumber == currentStep;

    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: isCompleted ? theme.colorScheme.primary : theme.disabledColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha((0.4 * 255).round()),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            color: isCompleted ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
            size: 26,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
          color: isCompleted
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withAlpha((0.7 * 255).round()),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((0.6 * 255).round()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(BuildContext context, int stepNumber) {
    final isCompleted = stepNumber < currentStep;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(left: 24, top: 8, bottom: 8),
      width: 3,
      height: 30,
      color: isCompleted ? theme.colorScheme.primary : theme.disabledColor,
    );
  }
}
