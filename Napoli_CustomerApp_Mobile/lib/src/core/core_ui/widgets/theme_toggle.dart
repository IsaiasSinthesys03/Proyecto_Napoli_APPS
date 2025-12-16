import 'package:flutter/material.dart';
import '../../../features/settings/presentation/screens/settings_screen.dart';

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.settings), // Icono de configuración único
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
      },
      tooltip: 'Configuración',
    );
  }
}
