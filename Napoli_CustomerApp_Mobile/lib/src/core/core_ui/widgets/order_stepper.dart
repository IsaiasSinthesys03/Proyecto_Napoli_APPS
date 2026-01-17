import 'package:flutter/material.dart';

class OrderStepper extends StatelessWidget {
  final int currentStep;

  const OrderStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.disabledColor.withOpacity(0.3);

    // Definimos los pasos con sus datos (Iconos temáticos de pizza)
    final steps = [
      _TrackerStep(
        title: 'Confirmado',
        subtitle: 'Tu orden ha sido recibida',
        icon: Icons.receipt_long_rounded,
      ),
      _TrackerStep(
        title: 'Preparando',
        subtitle: 'En el horno de leña',
        icon: Icons.local_fire_department_rounded,
      ),
      _TrackerStep(
        title: 'En camino',
        subtitle: 'El repartidor va hacia ti',
        icon: Icons.delivery_dining_rounded,
      ),
      _TrackerStep(
        title: 'Entregado',
        subtitle: '¡A disfrutar!',
        icon: Icons.local_pizza_rounded,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            // Columna del Paso (Icono + Texto)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icono
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Center(
                    child: _PulsingTrackerIcon(
                      icon: steps[i].icon,
                      isActive: i == currentStep,
                      isCompleted: i < currentStep,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Texto (con más ancho para evitar cortes)
                SizedBox(
                  width: 70,
                  child: Text(
                    steps[i].title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: i == currentStep
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: i <= currentStep
                          ? theme.colorScheme.onSurface
                          : theme.disabledColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            // Línea conectora (si no es el último)
            if (i < steps.length - 1)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                    top: 24,
                  ), // Alineado al centro del icono (50/2 - altura_linea/2)
                  height: 2,
                  color: i < currentStep ? activeColor : inactiveColor,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TrackerStep {
  final String title;
  final String subtitle;
  final IconData icon;

  _TrackerStep({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

class _PulsingTrackerIcon extends StatefulWidget {
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final Color activeColor;
  final Color inactiveColor;

  const _PulsingTrackerIcon({
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  State<_PulsingTrackerIcon> createState() => _PulsingTrackerIconState();
}

class _PulsingTrackerIconState extends State<_PulsingTrackerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.4,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fadeAnimation = Tween<double>(
      begin: 0.6,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = (widget.isActive || widget.isCompleted)
        ? widget.activeColor
        : widget.inactiveColor;

    return Stack(
      alignment: Alignment.center,
      children: [
        if (widget.isActive)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.4),
                    ),
                  ),
                ),
              );
            },
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOutBack,
          width: widget.isActive ? 48 : 40,
          height: widget.isActive ? 48 : 40,
          decoration: BoxDecoration(
            color: widget.isActive
                ? color.withOpacity(0.1)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: widget.isActive ? 2.5 : 2.0,
            ),
          ),
          child: Icon(
            widget.isCompleted ? Icons.check : widget.icon,
            color: color,
            size: widget.isActive ? 24 : 20,
          ),
        ),
      ],
    );
  }
}
