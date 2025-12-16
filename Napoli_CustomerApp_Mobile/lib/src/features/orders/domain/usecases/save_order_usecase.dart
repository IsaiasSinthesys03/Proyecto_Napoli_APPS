import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

@lazySingleton
class SaveOrderUseCase implements UseCase<Order, SaveOrderParams> {
  final OrderRepository _repository;

  SaveOrderUseCase(this._repository);

  @override
  Future<Either<Failure, Order>> call(SaveOrderParams params) async {
    // Create order in Supabase (not just local storage)
    return await _repository.createOrder(params.order, params.customerId);
  }
}

class SaveOrderParams extends Equatable {
  final Order order;
  final String customerId;

  const SaveOrderParams({required this.order, required this.customerId});

  @override
  List<Object?> get props => [order, customerId];
}
