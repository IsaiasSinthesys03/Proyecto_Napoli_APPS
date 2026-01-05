import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource real para el dashboard usando Supabase
class SupabaseDashboardDataSource {
  final SupabaseClient _client;

  const SupabaseDashboardDataSource(this._client);

  /// Cambia el estado online del driver llamando al stored procedure
  Future<bool> setOnlineStatus(String driverId, bool isOnline) async {
    try {
      print('🔍 DEBUG - setOnlineStatus called');
      print('📦 DATA - driverId: $driverId, isOnline: $isOnline');

      final response = await _client.rpc(
        'toggle_driver_online_status',
        params: {'p_driver_id': driverId, 'p_is_online': isOnline},
      );

      print('✅ SUCCESS - RPC response: $response');

      if (response != null && response['success'] == true) {
        return response['is_online'] as bool;
      }

      return isOnline;
    } catch (e) {
      print('❌ ERROR - Failed to update online status: $e');
      rethrow;
    }
  }

  /// Obtiene el estado online del driver desde la base de datos
  Future<bool> getOnlineStatus(String driverId) async {
    try {
      final response = await _client
          .from('drivers')
          .select('is_online')
          .eq('id', driverId)
          .maybeSingle();

      if (response == null) {
        print('⚠️ WARNING - Driver not found: $driverId');
        return false;
      }

      return response['is_online'] as bool? ?? false;
    } catch (e) {
      print('❌ ERROR - Failed to get online status: $e');
      return false;
    }
  }
}
