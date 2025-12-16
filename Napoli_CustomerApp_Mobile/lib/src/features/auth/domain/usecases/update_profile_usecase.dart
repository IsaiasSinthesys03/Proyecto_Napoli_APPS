import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/user_model.dart';
import '../repositories/auth_repository.dart';

@lazySingleton
class UpdateProfileUseCase implements UseCase<UserModel, UpdateProfileParams> {
  final AuthRepository _repository;

  UpdateProfileUseCase(this._repository);

  @override
  Future<Either<Failure, UserModel>> call(UpdateProfileParams params) async {
    return await _repository.updateProfile(params.user);
  }
}

class UpdateProfileParams {
  final UserModel user;

  UpdateProfileParams({required this.user});
}
