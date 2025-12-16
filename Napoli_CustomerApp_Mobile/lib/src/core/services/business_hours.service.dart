import 'package:injectable/injectable.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';

@lazySingleton
class BusinessHoursService {
  final RestaurantConfigService _configService;

  BusinessHoursService(this._configService);

  // Helper to map weekday number to key
  String _getDayKey(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    // weekday is 1-7 (Mon-Sun), array is 0-6
    return days[weekday - 1];
  }

  // Parse "HH:mm" to double hours (e.g. "17:30" -> 17.5)
  double? _parseTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final parts = timeStr.split(':');
    if (parts.length != 2) return null;
    return int.parse(parts[0]) + (int.parse(parts[1]) / 60.0);
  }

  /// Verifica si el negocio está abierto en este momento
  Future<bool> isOpen() async {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Lunes, 7 = Domingo
    final currentHour = now.hour + (now.minute / 60.0);

    final config = await _configService.getBusinessHours();
    if (config.isEmpty) return false;

    final dayKey = _getDayKey(weekday);
    final dayConfig = config[dayKey] as Map<String, dynamic>?;

    if (dayConfig == null ||
        (dayConfig['enabled'] as bool? ?? false) == false) {
      return false;
    }

    final openTime = _parseTime(dayConfig['open'] as String?);
    final closeTime = _parseTime(dayConfig['close'] as String?);

    if (openTime == null || closeTime == null) return false;

    // Handle closing after midnight (e.g. 17:00 to 02:00)
    if (closeTime < openTime) {
      return currentHour >= openTime || currentHour < closeTime;
    }

    return currentHour >= openTime && currentHour < closeTime;
  }

  /// Verifica si está cerca de cerrar (1 hora antes)
  Future<bool> isClosingSoon() async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final currentHour = now.hour + (now.minute / 60.0);

    final config = await _configService.getBusinessHours();
    if (config.isEmpty) return false;

    final dayKey = _getDayKey(weekday);
    final dayConfig = config[dayKey] as Map<String, dynamic>?;

    if (dayConfig == null ||
        (dayConfig['enabled'] as bool? ?? false) == false) {
      return false;
    }

    final closeTime = _parseTime(dayConfig['close'] as String?);
    if (closeTime == null) return false;

    // Si falta 1 hora o menos para cerrar
    // Note: This logic is simplified for closing after midnight edge cases
    double diff = closeTime - currentHour;
    if (diff < 0) diff += 24;

    return diff <= 1.0 && diff > 0;
  }

  /// Obtiene el mensaje de horarios
  Future<String> getBusinessHoursMessage() async {
    final config = await _configService.getBusinessHours();
    if (config.isEmpty) return 'Horarios no disponibles';

    final buffer = StringBuffer('Horarios de Atención:\n');

    for (int i = 1; i <= 7; i++) {
      final dayKey = _getDayKey(i);
      final dayName = _getDayName(i);
      final dayConfig = config[dayKey] as Map<String, dynamic>?;

      if (dayConfig == null ||
          (dayConfig['enabled'] as bool? ?? false) == false) {
        buffer.writeln('• $dayName: CERRADO');
      } else {
        final openStr = _formatTimeStr(dayConfig['open'] as String?);
        final closeStr = _formatTimeStr(dayConfig['close'] as String?);
        buffer.writeln('• $dayName: $openStr - $closeStr');
      }
    }

    return buffer.toString();
  }

  String _formatTimeStr(String? time) {
    if (time == null) return '';
    final parts = time.split(':');
    if (parts.length != 2) return time;
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final suffix = hour >= 12 ? 'PM' : 'AM';
    final formattedHour = hour > 12
        ? hour - 12
        : hour == 0
        ? 12
        : hour;
    return '$formattedHour:$minute $suffix';
  }

  /// Obtiene el próximo horario de apertura
  Future<String> getNextOpeningTime() async {
    final now = DateTime.now();
    final weekday = now.weekday;
    final currentHour = now.hour + (now.minute / 60.0);

    final config = await _configService.getBusinessHours();
    if (config.isEmpty) return 'Próximamente';

    // 1. Check if opening later today
    final todayKey = _getDayKey(weekday);
    final todayConfig = config[todayKey] as Map<String, dynamic>?;

    if (todayConfig != null && (todayConfig['enabled'] as bool? ?? false)) {
      final openTime = _parseTime(todayConfig['open'] as String?);
      if (openTime != null && currentHour < openTime) {
        return 'Hoy a las ${_formatTimeStr(todayConfig['open'] as String?)}';
      }
    }

    // 2. Check subsequent days
    for (int i = 1; i <= 7; i++) {
      final nextDay = (weekday + i - 1) % 7 + 1; // 1-7
      final nextDayKey = _getDayKey(nextDay);
      final nextDayConfig = config[nextDayKey] as Map<String, dynamic>?;

      if (nextDayConfig != null &&
          (nextDayConfig['enabled'] as bool? ?? false)) {
        final openTimeStr = nextDayConfig['open'] as String?;
        if (openTimeStr != null) {
          final dayName = _getDayName(nextDay);
          return '$dayName a las ${_formatTimeStr(openTimeStr)}';
        }
      }
    }

    return 'Próximamente';
  }

  /// Obtiene el horario de hoy
  Future<String> getTodayHours() async {
    final now = DateTime.now();
    final config = await _configService.getBusinessHours();
    if (config.isEmpty) return 'CERRADO';

    final dayKey = _getDayKey(now.weekday);
    final dayConfig = config[dayKey] as Map<String, dynamic>?;

    if (dayConfig == null ||
        (dayConfig['enabled'] as bool? ?? false) == false) {
      return 'CERRADO';
    }

    final openStr = _formatTimeStr(dayConfig['open'] as String?);
    final closeStr = _formatTimeStr(dayConfig['close'] as String?);
    return '$openStr - $closeStr';
  }

  /// Obtiene el nombre del día
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Lunes';
      case 2:
        return 'Martes';
      case 3:
        return 'Miércoles';
      case 4:
        return 'Jueves';
      case 5:
        return 'Viernes';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }
}
