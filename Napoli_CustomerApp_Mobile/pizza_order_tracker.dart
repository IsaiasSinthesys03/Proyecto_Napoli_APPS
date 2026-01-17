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
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isActive = index == currentStep;
        final isCompleted = index < currentStep;
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de la línea de tiempo e iconos
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    // El Icono/Indicador
                    _AnimatedTrackerIcon(
                      icon: step.icon,
                      isActive: isActive,
                      isCompleted: isCompleted,
                      activeColor: activeColor,
                      inactiveColor: inactiveColor,
                    ),
                    // La Línea conectora (si no es el último)
                    if (!isLast)
                      Expanded(
                        child: _AnimatedLine(
                          isCompleted: isCompleted,
                          color: activeColor,
                          inactiveColor: inactiveColor,
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

class _AnimatedTrackerIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  final Color activeColor;
  final Color inactiveColor;

  const _AnimatedTrackerIcon({
    required this.icon,
    required this.isActive,
    required this.isCompleted,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = (isActive || isCompleted) ? activeColor : inactiveColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutBack,
      width: isActive ? 48 : 40,
      height: isActive ? 48 : 40,
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: isActive ? 2.5 : 2.0),
      ),
      child: Icon(
        isCompleted ? Icons.check : icon,
        color: color,
        size: isActive ? 24 : 20,
      ),
    );
  }
}

class _AnimatedLine extends StatelessWidget {
  final bool isCompleted;
  final Color color;
  final Color inactiveColor;

  const _AnimatedLine({
    required this.isCompleted,
    required this.color,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 3,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: inactiveColor,
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.topCenter,
        heightFactor: isCompleted ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }
}
