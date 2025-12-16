import 'package:flutter/material.dart';

/// Paleta de colores de la aplicación (Napoli Pizzeria)
/// Basada en la identidad visual de Barrio Napoli con tonos tierra, verde corporativo y rojo CTA
class AppColors {
  // ============================================
  // COLORES PRINCIPALES - IDENTIDAD DE MARCA
  // ============================================
  
  /// Verde corporativo principal - Color de marca (#006A4E)
  static const Color primaryGreen = Color(0xFF006A4E);
  
  /// Rojo para Call-to-Action y elementos críticos (#D93025)
  static const Color primaryRed = Color(0xFFD93025);
  
  /// Texto oscuro principal - Gris pizarra para legibilidad (#333333)
  static const Color textDark = Color(0xFF333333);
  
  /// Verde de éxito/confirmación (#4CAF50)
  static const Color successGreen = Color(0xFF4CAF50);
  
  /// Naranja de advertencia (#FF9800)
  static const Color warningOrange = Color(0xFFFF9800);
  
  /// Rojo de error (#E53935)
  static const Color errorRed = Color(0xFFE53935);
  
  // ============================================
  // TEMA CLARO - TONOS CÁLIDOS PIZZERÍA
  // ============================================
  
  /// Background principal tema claro - Gris claro neutro (#F5F5F5)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  
  /// Surface de tarjetas tema claro - Blanco puro (#FFFFFF)
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  /// Beige cálido para acentos - Tono pizzería (#F5E6D3)
  static const Color accentBeige = Color(0xFFF5E6D3);
  
  /// Beige muy claro para fondos suaves (#FFF7F2)
  static const Color accentBeigeLight = Color(0xFFFFF7F2);
  
  /// Texto en superficie clara - Gris oscuro legible (#333333)
  static const Color onSurfaceLight = Color(0xFF333333);
  
  /// Texto secundario tema claro - Gris medio (#666666)
  static const Color textSecondaryLight = Color(0xFF666666);
  
  /// Bordes y divisores tema claro - Gris claro (#E0E0E0)
  static const Color dividerLight = Color(0xFFE0E0E0);
  
  /// Fill de inputs tema claro - Gris muy claro (#F5F5F5)
  static const Color inputFillLight = Color(0xFFF5F5F5);
  
  // ============================================
  // TEMA OSCURO - TONOS PROFUNDOS Y ELEGANTES
  // ============================================
  
  /// Background principal tema oscuro - Negro carbón (#121212)
  static const Color backgroundDark = Color(0xFF121212);
  
  /// Surface de tarjetas tema oscuro - Gris oscuro (#1E1E1E)
  static const Color surfaceDark = Color(0xFF1E1E1E);
  
  /// Surface elevada tema oscuro - Gris medio oscuro (#2A2A2A)
  static const Color surfaceElevatedDark = Color(0xFF2A2A2A);
  
  /// Texto en superficie oscura - Gris muy claro (#EEEEEE)
  static const Color onSurfaceDark = Color(0xFFEEEEEE);
  
  /// Texto secundario tema oscuro - Gris medio (#C0C0C0)
  static const Color textSecondaryDark = Color(0xFFC0C0C0);
  
  /// Bordes y divisores tema oscuro - Gris oscuro (#444444)
  static const Color dividerDark = Color(0xFF444444);
  
  /// Fill de inputs tema oscuro - Gris muy oscuro (#2A2A2A)
  static const Color inputFillDark = Color(0xFF2A2A2A);
  
  // ============================================
  // COLORES UNIVERSALES
  // ============================================
  
  /// Blanco puro - Universal (#FFFFFF)
  static const Color white = Color(0xFFFFFFFF);
  
  /// Negro puro - Universal (#000000)
  static const Color black = Color(0xFF000000);
  
  /// Transparente
  static const Color transparent = Colors.transparent;
  
  // ============================================
  // GRADIENTES Y EFECTOS (tonos pizzería)
  // ============================================
  
  /// Marrón tierra muy oscuro para gradientes (#3D2817)
  static const Color earthBrownDark = Color(0xFF3D2817);
  
  /// Marrón tierra medio para gradientes (#4A3728)
  static const Color earthBrownMedium = Color(0xFF4A3728);
  
  /// Naranja cálido para gradientes de fuego (#FFB347)
  static const Color fireOrange = Color(0xFFFFB347);
  
  /// Rojo tostado para gradientes (#A82015)
  static const Color toastedRed = Color(0xFFA82015);
}

/// Clase de tema de la aplicación siguiendo Arquitectura V5
class AppTheme {
  // Radios de esquinas estandarizados
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;

  // Espaciados estandarizados
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  /// Obtiene el tema claro de la aplicación
  static ThemeData getLightTheme() {
    // Define el ColorScheme completo para el modo claro
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,

      // Colores principales corporativos
      primary: AppColors.primaryGreen,           // Verde corporativo #006A4E
      onPrimary: AppColors.white,

      secondary: AppColors.primaryRed,           // Rojo CTA #D93025
      onSecondary: AppColors.white,

      tertiary: AppColors.accentBeige,           // Beige cálido #F5E6D3
      onTertiary: AppColors.textDark,

      // Superficies y fondos
      surface: AppColors.surfaceLight,           // Blanco puro #FFFFFF
      onSurface: AppColors.onSurfaceLight,       // Texto oscuro #333333

      // Color de errores
      error: AppColors.errorRed,
      onError: AppColors.white,
    );

    // Construye el ThemeData usando el ColorScheme
    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: 'Avenir',

      // El tema del texto usará `colorScheme.onSurface` por defecto
      textTheme: const TextTheme().apply(
        bodyColor: lightColorScheme.onSurface,
        displayColor: lightColorScheme.onSurface,
      ),

      // Fondo principal - Gris claro neutro
      scaffoldBackgroundColor: AppColors.backgroundLight,
      canvasColor: AppColors.backgroundLight,

      // Tema de AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: lightColorScheme.surface,
        foregroundColor: lightColorScheme.onSurface,
        elevation: 1,
        centerTitle: false,
        iconTheme: IconThemeData(color: lightColorScheme.primary),
        titleTextStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: lightColorScheme.onSurface,
        ),
      ),

      // Tema de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightColorScheme.secondary,  // Rojo CTA
          foregroundColor: lightColorScheme.onSecondary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema de botones filled
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: lightColorScheme.secondary,  // Rojo CTA
          foregroundColor: lightColorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema de botones outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightColorScheme.primary,
          side: BorderSide(color: lightColorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Tema de cards
      cardTheme: CardThemeData(
        color: lightColorScheme.surface,  // Blanco para tarjetas
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        shadowColor: AppColors.black.withAlpha((0.08 * 255).round()),
      ),

      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillLight,  // Gris muy claro
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryLight,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryLight.withAlpha((0.6 * 255).round()),
        ),
      ),

      // Tema de iconos
      iconTheme: IconThemeData(
        color: lightColorScheme.onSurface,
      ),

      // Tema de dividers
      dividerTheme: DividerThemeData(
        color: AppColors.dividerLight,
        thickness: 1,
      ),

      // Tema de SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textDark,
        contentTextStyle: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }

  /// Obtiene el tema oscuro de la aplicación
  static ThemeData getDarkTheme() {
    // Define el ColorScheme completo para el modo oscuro
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,

      // Colores principales corporativos
      primary: AppColors.primaryGreen,           // Verde corporativo #006A4E
      onPrimary: AppColors.white,

      secondary: AppColors.primaryRed,           // Rojo CTA #D93025
      onSecondary: AppColors.white,

      tertiary: AppColors.accentBeige,           // Beige cálido
      onTertiary: AppColors.textDark,

      // Superficies y fondos oscuros
      surface: AppColors.surfaceDark,            // Gris oscuro #1E1E1E
      onSurface: AppColors.onSurfaceDark,        // Gris muy claro #EEEEEE

      // Color de errores
      error: AppColors.errorRed,
      onError: AppColors.white,
    );

    // Construye el ThemeData usando el ColorScheme
    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: 'Avenir',

      // El tema del texto usará `colorScheme.onSurface` por defecto
      textTheme: const TextTheme().apply(
        bodyColor: darkColorScheme.onSurface,
        displayColor: darkColorScheme.onSurface,
      ),

      // Fondo principal - Negro carbón
      scaffoldBackgroundColor: AppColors.backgroundDark,
      canvasColor: AppColors.backgroundDark,

      // Tema de AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        elevation: 2,
        centerTitle: false,
        iconTheme: IconThemeData(color: darkColorScheme.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
      ),

      // Tema de botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkColorScheme.secondary,  // Rojo CTA
          foregroundColor: darkColorScheme.onSecondary,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema de botones filled
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: darkColorScheme.secondary,  // Rojo CTA
          foregroundColor: darkColorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Avenir',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Tema de botones outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkColorScheme.primary,
          side: BorderSide(color: darkColorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        ),
      ),

      // Tema de cards
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevatedDark,  // Gris medio oscuro #2A2A2A
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        shadowColor: AppColors.black.withAlpha((0.3 * 255).round()),
      ),

      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark,  // Gris muy oscuro
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: BorderSide(color: darkColorScheme.error, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryDark.withAlpha((0.6 * 255).round()),
        ),
      ),

      // Tema de iconos
      iconTheme: IconThemeData(
        color: darkColorScheme.onSurface,
      ),

      // Tema de dividers
      dividerTheme: DividerThemeData(
        color: AppColors.dividerDark,
        thickness: 1,
      ),

      // Tema de SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceElevatedDark,
        contentTextStyle: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.onSurfaceDark,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
    );
  }
}

// Mantener compatibilidad con código existente
final lightTheme = AppTheme.getLightTheme();
final darkTheme = AppTheme.getDarkTheme();
