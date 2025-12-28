import 'package:flutter/material.dart';

/// Sistema de tipografía de Napoli Drivers App
/// Basado en la fuente Avenir
class AppTextStyles {
  static const String _fontFamily = 'Avenir';

  // ============================================
  // HEADINGS
  // ============================================

  static const TextStyle h1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  static const TextStyle h4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    height: 1.4,
  );

  // ============================================
  // BODY TEXT
  // ============================================

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // ============================================
  // SPECIAL PURPOSE
  // ============================================

  static const TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.5,
  );

  // ============================================
  // DRIVERS APP SPECIFIC
  // ============================================

  /// Estilo para números de pedido (#1234)
  static const TextStyle orderNumber = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w900,
    letterSpacing: 1.0,
  );

  /// Estilo para nombres de repartidores
  static const TextStyle driverName = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  /// Estilo para direcciones
  static const TextStyle address = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
}
