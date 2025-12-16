import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

@lazySingleton
class ClearCartUseCase implements UseCase<void, NoParams> {
  final CartRepository _repository;

  ClearCartUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await _repository.clearCart();
  }
}
