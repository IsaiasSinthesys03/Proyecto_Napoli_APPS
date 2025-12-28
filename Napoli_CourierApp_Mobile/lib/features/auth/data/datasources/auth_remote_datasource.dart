import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/driver_model.dart';

/// DataSource remoto para autenticación usando Supabase
class AuthRemoteDataSource {
  final SupabaseClient _client;

  AuthRemoteDataSource(this._client);

  /// Login con email y password usando  /// Login de driver
  Future<DriverModel> login({
    required String email,
    required String password,
  }) async {
    try {
      // 1. Autenticar con Supabase Auth
      final authResponse = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error de autenticación');
      }

      // 2. Llamar stored procedure para obtener driver (bypasses RLS)
      final result = await _client.rpc(
        'login_driver',
        params: {'p_email': email},
      );

      // 3. Convertir a DriverModel
      final driverModel = DriverModel.fromJson(result as Map<String, dynamic>);

      // 4. Validar status
      final status = driverModel.status;
      if (status != 'approved' && status != 'active') {
        throw Exception(
          'Tu cuenta está pendiente de aprobación por el administrador',
        );
      }

      return driverModel;
    } on AuthException catch (e) {
      throw Exception('Error al iniciar sesión: ${e.message}');
    } on PostgrestException catch (e) {
      throw Exception('Error en la base de datos: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  /// Registro de nuevo driver
  Future<DriverModel> register({
    required String restaurantId,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    String? photoUrl,
  }) async {
    try {
      // 🔍 DEBUG: Ver datos que se envían
      print('🔍 DEBUG - Starting registration');
      print('🔍 restaurant_id: $restaurantId (${restaurantId.runtimeType})');
      print('🔍 name: $name');
      print('🔍 email: $email');
      print('🔍 vehicle_type: $vehicleType');

      // 1. Crear usuario en Supabase Auth
      final authResponse = await _client.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Error al crear usuario');
      }

      print('✅ Auth user created: ${authResponse.user!.id}');

      // 2. Llamar stored procedure en lugar de INSERT directo
      print('🔍 DEBUG - Calling stored procedure');

      final result = await _client.rpc(
        'register_driver',
        params: {
          'p_restaurant_id': restaurantId,
          'p_name': name,
          'p_email': email,
          'p_phone': phone,
          'p_vehicle_type': vehicleType,
          'p_license_plate': licensePlate,
          'p_photo_url': photoUrl,
        },
      );

      print('✅ Driver created via stored procedure');
      print('🔍 Result: $result');

      // 3. Convertir a DriverModel
      return DriverModel.fromJson(result as Map<String, dynamic>);
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message}');
      throw Exception('Error al registrar: ${e.message}');
    } on PostgrestException catch (e) {
      print('❌ Database error: ${e.message}');
      print('❌ Error code: ${e.code}');
      print('❌ Error details: ${e.details}');
      throw Exception('Error en la base de datos: ${e.message}');
    } catch (e) {
      print('❌ Unknown error: $e');
      throw Exception('Error al registrar: $e');
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Error al cerrar sesión: $e');
    }
  }

  /// Obtener driver actual
  Future<DriverModel?> getCurrentDriver() async {
    try {
      final user = _client.auth.currentUser;

      if (user == null) {
        return null;
      }

      // Obtener datos del driver desde la tabla
      final driverData = await _client
          .from('drivers')
          .select()
          .eq('email', user.email!)
          .maybeSingle();

      if (driverData == null) {
        return null;
      }

      return DriverModel.fromJson(driverData);
    } catch (e) {
      throw Exception('Error al obtener driver actual: $e');
    }
  }

  /// Actualizar driver
  Future<DriverModel> updateDriver(DriverModel driver) async {
    try {
      final driverData = await _client
          .from('drivers')
          .update(driver.toJson())
          .eq('id', driver.id)
          .select()
          .single();

      return DriverModel.fromJson(driverData);
    } catch (e) {
      throw Exception('Error al actualizar driver: $e');
    }
  }
}
