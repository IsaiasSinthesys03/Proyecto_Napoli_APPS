import 'package:fpdart/fpdart.dart';
import '../entities/driver.dart';
import '../repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<String, Driver>> call({
    required String email,
    required String password,
  }) async {
    // Validaciones básicas
    if (email.isEmpty) {
      return left('El email es requerido');
    }
    if (password.isEmpty) {
      return left('La contraseña es requerida');
    }
    if (password.length < 6) {
      return left('La contraseña debe tener al menos 6 caracteres');
    }

    // Delegar al repositorio
    return repository.login(email: email, password: password);
  }
}
