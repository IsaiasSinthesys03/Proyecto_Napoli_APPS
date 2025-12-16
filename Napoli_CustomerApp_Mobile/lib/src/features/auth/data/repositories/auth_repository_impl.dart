import 'dart:convert';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/services/local_storage_service.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final LocalStorageService _localStorageService;
  final AuthRemoteDataSource _remoteDataSource;
  static const String _userKey = 'current_user';

  AuthRepositoryImpl(this._localStorageService, this._remoteDataSource);

  @override
  Future<Either<Failure, UserModel>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.login(email, password);
      await _saveUser(user);
      return Right(user);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final user = await _remoteDataSource.register(name, email, password);
      await _saveUser(user);
      return Right(user);
    } catch (e) {
      return const Left(ServerFailure('Error al registrar usuario'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localStorageService.remove(_userKey);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Error al cerrar sesión'));
    }
  }

  @override
  Future<Either<Failure, UserModel?>> getCurrentUser() async {
    try {
      final userJson = _localStorageService.getString(_userKey);
      if (userJson != null) {
        return Right(UserModel.fromJson(jsonDecode(userJson)));
      }
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Error al obtener usuario actual'));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateProfile(UserModel user) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(user);
      await _saveUser(updatedUser);
      return Right(updatedUser);
    } catch (e) {
      return const Left(CacheFailure('Error al actualizar perfil'));
    }
  }

  Future<void> _saveUser(UserModel user) async {
    await _localStorageService.setString(_userKey, jsonEncode(user.toJson()));
  }
}
