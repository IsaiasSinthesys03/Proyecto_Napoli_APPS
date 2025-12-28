import 'package:fpdart/fpdart.dart';
import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo repartidor
class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  /// Registra un nuevo repartidor
  /// Retorna Either con error (Left) o Driver registrado (Right)
  Future<Either<String, Driver>> call({
    required String restaurantId,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    String? photoUrl,
  }) async {
    // Validaciones básicas
    if (name.trim().isEmpty) {
      return left('El nombre es requerido');
    }

    if (email.trim().isEmpty || !_isValidEmail(email)) {
      return left('Email inválido');
    }

    if (password.length < 6) {
      return left('La contraseña debe tener al menos 6 caracteres');
    }

    if (phone.trim().isEmpty) {
      return left('El teléfono es requerido');
    }

    if (licensePlate.trim().isEmpty) {
      return left('La placa es requerida');
    }

    // Llamar al repositorio
    return repository.register(
      restaurantId: restaurantId,
      name: name,
      email: email,
      password: password,
      phone: phone,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      photoUrl: photoUrl,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}
