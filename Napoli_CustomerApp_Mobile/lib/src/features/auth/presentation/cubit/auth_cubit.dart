import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../data/models/user_model.dart';
import '../../../../core/usecases/usecase.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LogoutUseCase _logoutUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;

  AuthCubit(
    this._loginUseCase,
    this._registerUseCase,
    this._getCurrentUserUseCase,
    this._logoutUseCase,
    this._updateProfileUseCase,
  ) : super(const AuthInitial());

  Future<void> checkAuth() async {
    emit(const AuthLoading());

    final result = await _getCurrentUserUseCase(NoParams());

    result.fold((failure) => emit(const Unauthenticated()), (user) {
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const Unauthenticated());
      }
    });
  }

  Future<void> login(String email, String password) async {
    emit(const AuthLoading());

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> register(String name, String email, String password) async {
    emit(const AuthLoading());

    final result = await _registerUseCase(
      RegisterParams(name: name, email: email, password: password),
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(Authenticated(user)),
    );
  }

  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _logoutUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const Unauthenticated()),
    );
  }

  Future<void> updateProfile(UserModel user) async {
    emit(const AuthLoading());

    final result = await _updateProfileUseCase(UpdateProfileParams(user: user));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (updatedUser) => emit(Authenticated(updatedUser)),
    );
  }
}
