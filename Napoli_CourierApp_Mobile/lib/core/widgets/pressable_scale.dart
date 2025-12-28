import 'package:flutter/material.dart';

/// Widget que añade efecto de escala táctil al presionar
/// Proporciona feedback visual inmediato al usuario
class PressableScale extends StatefulWidget {
  final Widget child;
  final double downScale;

  const PressableScale({required this.child, this.downScale = 0.96, super.key});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  double _scale = 1.0;

  void _down([TapDownDetails? _]) => setState(() => _scale = widget.downScale);
  void _up([dynamic _]) => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: _up,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
