import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Clase de tema de la aplicación siguiendo Material 3
class AppTheme {
  /// Obtiene el tema claro de la aplicación
  static ThemeData getLightTheme() {
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      // Colores principales corporativos
      primary: AppColors.primaryGreen, // Verde corporativo #006A4E
      onPrimary: AppColors.white,
      secondary: AppColors.primaryRed, // Rojo CTA #D93025
      onSecondary: AppColors.white,
      tertiary: AppColors.accentBeige, // Beige cálido #F5E6D3
      onTertiary: AppColors.textDark,
      // Superficies y fondos
      surface: AppColors.surfaceLight, // Blanco puro #FFFFFF
      onSurface: AppColors.onSurfaceLight, // Texto oscuro #333333
      // Color de errores
      error: AppColors.errorRed,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: 'Avenir',
      // El tema del texto usará colorScheme.onSurface por defecto
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
          backgroundColor: lightColorScheme.secondary, // Rojo CTA
          foregroundColor: lightColorScheme.onSecondary,
          elevation: AppDimensions.elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingM,
            horizontal: AppDimensions.spacingL,
          ),
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
          backgroundColor: lightColorScheme.secondary, // Rojo CTA
          foregroundColor: lightColorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingM,
            horizontal: AppDimensions.spacingL,
          ),
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingM,
            horizontal: AppDimensions.spacingL,
          ),
        ),
      ),
      // Tema de cards
      cardTheme: CardThemeData(
        color: lightColorScheme.surface, // Blanco para tarjetas
        elevation: AppDimensions.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        shadowColor: AppColors.black.withValues(alpha: 0.08),
      ),
      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillLight, // Gris muy claro
        contentPadding: const EdgeInsets.all(AppDimensions.spacingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: lightColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: lightColorScheme.error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryLight,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryLight.withValues(alpha: 0.6),
        ),
      ),
      // Tema de iconos
      iconTheme: IconThemeData(color: lightColorScheme.onSurface),
      // Tema de dividers
      dividerTheme: const DividerThemeData(
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
    );
  }

  /// Obtiene el tema oscuro de la aplicación
  static ThemeData getDarkTheme() {
    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      // Colores principales corporativos
      primary: AppColors.primaryGreen, // Verde corporativo #006A4E
      onPrimary: AppColors.white,
      secondary: AppColors.primaryRed, // Rojo CTA #D93025
      onSecondary: AppColors.white,
      tertiary: AppColors.accentBeige, // Beige cálido
      onTertiary: AppColors.textDark,
      // Superficies y fondos oscuros
      surface: AppColors.surfaceDark, // Gris oscuro #1E1E1E
      onSurface: AppColors.onSurfaceDark, // Gris muy claro #EEEEEE
      // Color de errores
      error: AppColors.errorRed,
      onError: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: 'Avenir',
      // El tema del texto usará colorScheme.onSurface por defecto
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
        elevation: AppDimensions.elevationLow,
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
          backgroundColor: darkColorScheme.secondary, // Rojo CTA
          foregroundColor: darkColorScheme.onSecondary,
          elevation: AppDimensions.elevationLow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingM,
            horizontal: AppDimensions.spacingL,
          ),
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
          backgroundColor: darkColorScheme.secondary, // Rojo CTA
          foregroundColor: darkColorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingM,
            horizontal: AppDimensions.spacingL,
          ),
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
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppDimensions.spacingM,
            horizontal: AppDimensions.spacingL,
          ),
        ),
      ),
      // Tema de cards
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevatedDark, // Gris medio oscuro #2A2A2A
        elevation: AppDimensions.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
        shadowColor: AppColors.black.withValues(alpha: 0.3),
      ),
      // Tema de inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFillDark, // Gris muy oscuro
        contentPadding: const EdgeInsets.all(AppDimensions.spacingM),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: darkColorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          borderSide: BorderSide(color: darkColorScheme.error, width: 2),
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryDark,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Avenir',
          fontSize: 14,
          color: AppColors.textSecondaryDark.withValues(alpha: 0.6),
        ),
      ),
      // Tema de iconos
      iconTheme: IconThemeData(color: darkColorScheme.onSurface),
      // Tema de dividers
      dividerTheme: const DividerThemeData(
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
    );
  }
}

// Mantener compatibilidad con código existente
final lightTheme = AppTheme.getLightTheme();
final darkTheme = AppTheme.getDarkTheme();
