import '../models/driver_model.dart';

/// DataSource mock para autenticación
/// Simula un backend con 2 usuarios pre-definidos
class MockAuthDataSource {
  // Base de datos en memoria
  static final List<DriverModel> _mockDrivers = [
    // Usuario 1: Repartidor APROBADO - Puede usar la app
    DriverModel(
      id: '1',
      restaurantId: 'mock-restaurant-id',
      name: 'Juan Pérez',
      email: 'repartidor@napoli.com',
      phone: '+5491123456789',
      photoUrl: null,
      vehicleType: 'moto',
      licensePlate: 'ABC123',
      status: 'approved', // ✅ APROBADO
      isOnline: false,
      isOnDelivery: false,
      createdAt: DateTime(2024, 1, 15).toIso8601String(),
      totalDeliveries: 145,
      ratingSum: 720,
      ratingCount: 150,
      averageRating: 4.8,
      totalEarningsCents: 725000,
    ),
    // Usuario 2: Repartidor PENDIENTE - Verá pantalla de espera
    DriverModel(
      id: '2',
      restaurantId: 'mock-restaurant-id',
      name: 'María García',
      email: 'nuevo@napoli.com',
      phone: '+5491198765432',
      photoUrl: null,
      vehicleType: 'bici',
      licensePlate: 'XYZ789',
      status: 'pending', // ⏳ PENDIENTE
      isOnline: false,
      isOnDelivery: false,
      createdAt: DateTime.now().toIso8601String(),
      totalDeliveries: 0,
      ratingSum: 0,
      ratingCount: 0,
      averageRating: 0.0,
      totalEarningsCents: 0,
    ),
  ];

  /// Simula login con delay de red
  Future<DriverModel?> login(String email, String password) async {
    // Simular delay de red (500ms)
    await Future.delayed(const Duration(milliseconds: 500));

    // Buscar usuario por email
    try {
      final driver = _mockDrivers.firstWhere(
        (d) => d.email.toLowerCase() == email.toLowerCase(),
      );

      // En mock, cualquier password de 6+ caracteres es válida
      if (password.length < 6) {
        throw Exception('Contraseña inválida');
      }

      return driver;
    } catch (e) {
      // Usuario no encontrado
      throw Exception('Credenciales inválidas');
    }
  }

  /// Simula registro de nuevo repartidor
  Future<DriverModel> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    String? profileImagePath,
  }) async {
    // Simular delay de red (800ms)
    await Future.delayed(const Duration(milliseconds: 800));

    // Verificar email único
    final emailExists = _mockDrivers.any(
      (d) => d.email.toLowerCase() == email.toLowerCase(),
    );

    if (emailExists) {
      throw Exception('El email ya está registrado');
    }

    // Crear nuevo repartidor con status PENDING
    final newDriver = DriverModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      restaurantId: 'mock-restaurant-id',
      name: name,
      email: email,
      phone: phone,
      photoUrl: profileImagePath,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      status: 'pending', // Siempre pending al registrarse
      isOnline: false,
      isOnDelivery: false,
      createdAt: DateTime.now().toIso8601String(),
      totalDeliveries: 0,
      ratingSum: 0,
      ratingCount: 0,
      averageRating: 0.0,
      totalEarningsCents: 0,
    );

    // Agregar a la "base de datos"
    _mockDrivers.add(newDriver);

    return newDriver;
  }

  /// Obtiene un driver por ID
  Future<DriverModel?> getDriverById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    try {
      return _mockDrivers.firstWhere((d) => d.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Actualiza un driver
  Future<DriverModel> updateDriver(DriverModel driver) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockDrivers.indexWhere((d) => d.id == driver.id);
    if (index == -1) {
      throw Exception('Driver no encontrado');
    }

    _mockDrivers[index] = driver;
    return driver;
  }
}
