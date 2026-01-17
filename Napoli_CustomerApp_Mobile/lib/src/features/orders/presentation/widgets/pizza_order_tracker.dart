import 'package:flutter/material.dart';

/// Un widget de seguimiento de pedidos personalizado y animado para Napoli Pizza.
/// Reemplaza los steppers verticales aburridos con iconos temáticos y animaciones.
class PizzaOrderTracker extends StatelessWidget {
  final int
  currentStep; // 0: Pendiente, 1: Preparando, 2: En camino, 3: Entregado
  final Color activeColor;
  final Color inactiveColor;

  const PizzaOrderTracker({
    Key? key,
    required this.currentStep,
    this.activeColor = const Color(0xFFFF4500), // OrangeRed por defecto
    this.inactiveColor = const Color(0xFFE0E0E0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(
        horizontal: 10.0,
      ), // Margen lateral extra
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Columna de la línea de tiempo e iconos
              SizedBox(
                width: 60,
                child: Stack(
                  children: [
                    // La Línea conectora (si no es el último)
                    if (!isLast)
                      Positioned(
                        top: 34, // Ajustado para empezar debajo del icono
                        bottom: 0,
                        left: 29, // Centrado con el icono (60/2 - width/2)
                        width: 2,
                        child: _DottedLine(
                          isActive:
                              isCompleted, // La línea se activa si el paso anterior se completó
                          color: activeColor,
                          inactiveColor: inactiveColor,
                        ),
                      ),
                    // El Icono/Indicador
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                        ),
                        child: _PulsingTrackerIcon(
                          icon: step.icon,
                          isActive: isActive,
                          isCompleted: isCompleted,
                          activeColor: activeColor,
                          inactiveColor: inactiveColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Columna de Textos
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 30.0,
                    right: 16.0,
                  ),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: (isActive || isCompleted) ? 1.0 : 0.5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          step.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: isActive
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isActive ? Colors.black87 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step.subtitle,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
        // Efecto de onda (Ripple) solo si está activo
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
        // Icono principal
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

class _DottedLine extends StatelessWidget {
  final bool isActive;
  final Color color;
  final Color inactiveColor;

  const _DottedLine({
    required this.isActive,
    required this.color,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        // Altura de cada punto y espacio
        const dotHeight = 4.0;
        const spacing = 3.0;

        // Calcular cuántos puntos caben
        final count = (height / (dotHeight + spacing)).floor();

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(count, (index) {
            return Container(
              width: 2,
              height: dotHeight,
              margin: const EdgeInsets.only(bottom: spacing),
              decoration: BoxDecoration(
                color: isActive ? color : inactiveColor,
                borderRadius: BorderRadius.circular(1),
              ),
            );
          }),
        );
      },
    );
  }
}
