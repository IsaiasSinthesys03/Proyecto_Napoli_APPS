import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../auth/domain/entities/driver.dart';
import 'profile_state.dart';

/// Cubit para manejar el perfil del conductor
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;
  final AuthRepository _authRepository;
  final SharedPreferences _prefs;
  String? _currentDriverId;

  ProfileCubit({
    required ProfileRepository repository,
    required AuthRepository authRepository,
    required SharedPreferences prefs,
  }) : _repository = repository,
       _authRepository = authRepository,
       _prefs = prefs,
       super(const ProfileInitial());

  /// Carga el perfil del conductor
  Future<void> loadProfile(String driverId) async {
    _currentDriverId = driverId;
    emit(const ProfileLoading());

    final result = await _repository.getProfile(driverId);

    result.fold(
      (error) => emit(ProfileError(error)),
      (profile) => emit(ProfileLoaded(profile)),
    );
  }

  /// Actualiza la información del conductor
  Future<void> updateDriver(Driver driver) async {
    emit(const ProfileUpdating());

    final result = await _repository.updateDriver(driver);

    result.fold((error) => emit(ProfileError(error)), (updatedDriver) async {
      // Recargar perfil completo usando el ID del driver actualizado
      final profileResult = await _repository.getProfile(driver.id);
      profileResult.fold(
        (error) => emit(ProfileError(error)),
        (profile) => emit(ProfileUpdated(profile)),
      );
    });
  }

  /// Cambia la contraseña del conductor
  Future<void> changePassword(String oldPassword, String newPassword) async {
    if (_currentDriverId == null) return;

    emit(const ProfileChangingPassword());

    final result = await _repository.changePassword(
      _currentDriverId!,
      oldPassword,
      newPassword,
    );

    result.fold(
      (error) => emit(ProfileError(error)),
      (_) => emit(const ProfilePasswordChanged()),
    );
  }

  /// Actualiza las configuraciones
  Future<void> updateSettings(Map<String, dynamic> settings) async {
    if (_currentDriverId == null) return;

    emit(const ProfileUpdating());

    final result = await _repository.updateSettings(
      _currentDriverId!,
      settings,
    );

    result.fold(
      (error) => emit(ProfileError(error)),
      (profile) => emit(ProfileUpdated(profile)),
    );
  }

  /// Cierra sesión del conductor
  Future<void> logout() async {
    try {
      // Limpiar sesión usando AuthRepository
      await _authRepository.logout();

      // Emitir estado inicial
      emit(const ProfileInitial());
    } catch (e) {
      emit(ProfileError('Error al cerrar sesión: $e'));
    }
  }

  /// Recarga el perfil después de una actualización
  Future<void> reloadProfile() async {
    if (_currentDriverId != null) {
      await loadProfile(_currentDriverId!);
    }
  }
}
