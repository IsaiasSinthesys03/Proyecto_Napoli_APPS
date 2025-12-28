import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

/// Cubit para gestionar el estado de autenticación
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final AuthRepository repository;

  AuthCubit({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.repository,
  }) : super(const AuthInitial());

  /// Intenta iniciar sesión
  Future<void> login({required String email, required String password}) async {
    emit(const AuthLoading());

    final result = await loginUseCase(email: email, password: password);

    result.fold((error) => emit(AuthError(error)), (driver) {
      // Verificar si el driver puede iniciar sesión
      if (driver.canLogin) {
        emit(Authenticated(driver));
      } else if (driver.isPending) {
        // Si está pendiente, mostrar pantalla de espera
        emit(Registered(driver));
      } else {
        emit(const AuthError('Tu cuenta no está activa'));
      }
    });
  }

  /// Registra un nuevo repartidor
  Future<void> register({
    required String restaurantId,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String vehicleType,
    required String licensePlate,
    String? photoUrl,
  }) async {
    emit(const AuthLoading());

    final result = await registerUseCase(
      restaurantId: restaurantId,
      name: name,
      email: email,
      password: password,
      phone: phone,
      vehicleType: vehicleType,
      licensePlate: licensePlate,
      photoUrl: photoUrl,
    );

    result.fold(
      (error) => emit(AuthError(error)),
      (driver) => emit(Registered(driver)),
    );
  }

  /// Cierra sesión
  Future<void> logout() async {
    await repository.logout();
    emit(const AuthInitial());
  }

  /// Verifica si hay una sesión activa
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    final driver = await repository.getCurrentDriver();

    if (driver != null && driver.canLogin) {
      emit(Authenticated(driver));
    } else {
      emit(const AuthInitial());
    }
  }
}
