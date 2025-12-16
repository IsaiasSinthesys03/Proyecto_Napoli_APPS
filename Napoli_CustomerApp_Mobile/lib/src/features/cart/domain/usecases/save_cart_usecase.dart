import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

@lazySingleton
class SaveCartUseCase implements UseCase<void, SaveCartParams> {
  final CartRepository _repository;

  SaveCartUseCase(this._repository);

  @override
  Future<Either<Failure, void>> call(SaveCartParams params) async {
    return await _repository.saveCart(params.items);
  }
}

class SaveCartParams extends Equatable {
  final List<CartItem> items;

  const SaveCartParams({required this.items});

  @override
  List<Object?> get props => [items];
}
