import 'package:shared_preferences/shared_preferences.dart';

/// DataSource mock para el dashboard
class MockDashboardDataSource {
  final SharedPreferences prefs;
  static const String _keyOnlineStatus = 'driver_online_status_';

  const MockDashboardDataSource(this.prefs);

  /// Cambia el estado online del driver
  Future<bool> setOnlineStatus(String driverId, bool isOnline) async {
    // Simular delay de red
    await Future.delayed(const Duration(milliseconds: 300));

    await prefs.setBool('$_keyOnlineStatus$driverId', isOnline);
    return isOnline;
  }

  /// Obtiene el estado online del driver
  Future<bool> getOnlineStatus(String driverId) async {
    return prefs.getBool('$_keyOnlineStatus$driverId') ?? false;
  }
}
