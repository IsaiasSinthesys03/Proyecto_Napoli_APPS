import 'package:equatable/equatable.dart';
import '../../domain/entities/driver_profile.dart';

/// Estados del ProfileCubit
sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Cargando perfil
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Perfil cargado exitosamente
class ProfileLoaded extends ProfileState {
  final DriverProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Error al cargar o actualizar perfil
class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Actualizando perfil
class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// Perfil actualizado exitosamente
class ProfileUpdated extends ProfileState {
  final DriverProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

/// Cambiando contraseña
class ProfileChangingPassword extends ProfileState {
  const ProfileChangingPassword();
}

/// Contraseña cambiada exitosamente
class ProfilePasswordChanged extends ProfileState {
  const ProfilePasswordChanged();
}
