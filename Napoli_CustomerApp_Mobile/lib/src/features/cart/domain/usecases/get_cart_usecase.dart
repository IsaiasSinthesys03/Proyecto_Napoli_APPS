import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

@lazySingleton
class GetCartUseCase implements UseCase<List<CartItem>, NoParams> {
  final CartRepository _repository;

  GetCartUseCase(this._repository);

  @override
  Future<Either<Failure, List<CartItem>>> call(NoParams params) async {
    return await _repository.getCart();
  }
}
