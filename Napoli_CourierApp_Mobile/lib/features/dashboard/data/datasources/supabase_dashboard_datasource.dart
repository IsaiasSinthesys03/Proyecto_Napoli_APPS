import 'package:supabase_flutter/supabase_flutter.dart';

/// DataSource de Supabase para el dashboard
class SupabaseDashboardDataSource {
  final SupabaseClient client;

  const SupabaseDashboardDataSource(this.client);

  /// Cambia el estado online del driver usando stored procedure
  Future<bool> setOnlineStatus(String driverId, bool isOnline) async {
    print(
      '🔍 DEBUG - setOnlineStatus called: driverId=$driverId, isOnline=$isOnline',
    );

    try {
      final response = await client.rpc(
        'toggle_driver_online_status',
        params: {'p_driver_id': driverId, 'p_is_online': isOnline},
      );

      print('✅ SUCCESS - Online status updated');

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
    print('🔍 DEBUG - getOnlineStatus called: driverId=$driverId');

    try {
      final response = await client
          .from('drivers')
          .select('is_online')
          .eq('id', driverId)
          .maybeSingle();

      if (response == null) {
        print('⚠️ WARNING - Driver not found');
        return false;
      }

      final isOnline = response['is_online'] as bool? ?? false;
      print('✅ SUCCESS - Online status retrieved: $isOnline');

      return isOnline;
    } catch (e) {
      print('❌ ERROR - Failed to get online status: $e');
      return false;
    }
  }
}
