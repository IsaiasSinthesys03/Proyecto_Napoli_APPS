import 'package:flutter/material.dart';

class AddressUtils {
  static IconData getLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'casa':
      case 'home':
        return Icons.home;
      case 'trabajo':
      case 'work':
        return Icons.work;
      case 'universidad':
      case 'uni':
      case 'escuela':
        return Icons.school;
      case 'gimnasio':
        return Icons.fitness_center;
      case 'familia':
        return Icons.family_restroom;
      case 'amigos':
        return Icons.people;
      case 'otro':
      case 'other':
        return Icons.place;
      default:
        return Icons.location_on;
    }
  }

  static Color getLabelColor(String label, ThemeData theme) {
    switch (label.toLowerCase()) {
      case 'casa':
      case 'home':
        return Colors.green;
      case 'trabajo':
      case 'work':
        return Colors.blue;
      case 'universidad':
      case 'uni':
      case 'escuela':
        return Colors.purple;
      case 'gimnasio':
        return Colors.orange;
      case 'familia':
        return Colors.pink;
      case 'amigos':
        return Colors.teal;
      case 'otro':
      case 'other':
        return Colors.grey;
      default:
        return theme.colorScheme.primary;
    }
  }
}
