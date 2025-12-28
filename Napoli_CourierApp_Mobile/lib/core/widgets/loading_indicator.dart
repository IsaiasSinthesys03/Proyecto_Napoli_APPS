import 'package:flutter/material.dart';

/// Indicador de carga estandarizado
class LoadingIndicator extends StatelessWidget {
  final Color? color;
  final double size;

  const LoadingIndicator({this.color, this.size = 40.0, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
