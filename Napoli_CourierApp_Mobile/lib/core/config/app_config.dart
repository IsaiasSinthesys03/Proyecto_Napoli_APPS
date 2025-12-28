/// Configuración global de la aplicación
class AppConfig {
  /// Restaurant ID por defecto
  /// Este ID debe coincidir con el restaurant_id en la base de datos
  static const String defaultRestaurantId =
      '06a5284c-0ef8-4efe-a882-ce1fc8319452';

  // Método para obtener el restaurant_id actual
  // Por ahora retorna el default, pero en el futuro puede ser dinámico
  static String getRestaurantId() {
    // TODO: En el futuro, obtener de:
    // - SharedPreferences (si el driver ya seleccionó)
    // - Deep link parameters
    // - Build configuration
    return defaultRestaurantId;
  }

  // Configuración de Supabase (ya existe en supabase_config.dart)
  // Aquí solo configuraciones específicas de la app
}
