import 'package:fpdart/fpdart.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

@lazySingleton
class GetOrdersUseCase implements UseCase<List<Order>, NoParams> {
  final OrderRepository _repository;

  GetOrdersUseCase(this._repository);

  @override
  Future<Either<Failure, List<Order>>> call(NoParams params) async {
    return await _repository.getOrders();
  }
}
