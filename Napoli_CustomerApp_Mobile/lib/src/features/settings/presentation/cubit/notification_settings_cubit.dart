import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:napoli_app_v1/src/features/auth/presentation/cubit/auth_state.dart';
import 'package:napoli_app_v1/src/features/settings/data/repositories/notification_settings_repository.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/notification_settings.dart';

// State
abstract class NotificationSettingsState extends Equatable {
  const NotificationSettingsState();
  @override
  List<Object?> get props => [];
}

class NotificationSettingsInitial extends NotificationSettingsState {}

class NotificationSettingsLoading extends NotificationSettingsState {}

class NotificationSettingsLoaded extends NotificationSettingsState {
  final NotificationSettings settings;
  const NotificationSettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class NotificationSettingsError extends NotificationSettingsState {
  final String message;
  const NotificationSettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

// Cubit
@injectable
class NotificationSettingsCubit extends Cubit<NotificationSettingsState> {
  final NotificationSettingsRepository _repository;
  final AuthCubit _authCubit; // To get customer ID

  NotificationSettingsCubit(this._repository, this._authCubit)
    : super(NotificationSettingsInitial()) {
    // Optionally auto-load if logic permits, but better driven by UI
  }

  Future<void> loadSettings() async {
    final authState = _authCubit.state;
    if (authState is! Authenticated) {
      emit(const NotificationSettingsError("Usuario no autenticado"));
      return;
    }

    try {
      emit(NotificationSettingsLoading());
      final settings = await _repository.getSettings(authState.user.id);
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      emit(NotificationSettingsError(e.toString()));
    }
  }

  Future<void> updateSettings(NotificationSettings settings) async {
    final authState = _authCubit.state;
    if (authState is! Authenticated) return;

    try {
      // Optimistic update would be nice, but simple for now
      await _repository.saveSettings(authState.user.id, settings);
      emit(NotificationSettingsLoaded(settings));
    } catch (e) {
      // emit(NotificationSettingsError(e.toString())); // Optionally show error, but maybe silent fail for toggles?
      // Re-load to revert UI
      loadSettings();
    }
  }
}
