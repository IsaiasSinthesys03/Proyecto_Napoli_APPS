import 'package:equatable/equatable.dart';
import '../../domain/entities/driver.dart';

/// Estados del AuthCubit
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - No autenticado
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Estado de carga (login o register en progreso)
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Estado autenticado - Usuario logueado exitosamente
class Authenticated extends AuthState {
  final Driver driver;

  const Authenticated(this.driver);

  @override
  List<Object?> get props => [driver];
}

/// Estado de error - Login o register fallido
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Estado de registro exitoso (usuario pending)
class Registered extends AuthState {
  final Driver driver;

  const Registered(this.driver);

  @override
  List<Object?> get props => [driver];
}
