import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../data/models/user_model.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserModel>> login(String email, String password);
  Future<Either<Failure, UserModel>> register(
    String name,
    String email,
    String password,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserModel?>> getCurrentUser();
  Future<Either<Failure, UserModel>> updateProfile(UserModel user);
}
