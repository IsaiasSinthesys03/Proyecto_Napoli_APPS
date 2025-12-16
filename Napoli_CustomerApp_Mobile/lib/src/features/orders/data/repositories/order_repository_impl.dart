import 'package:fpdart/fpdart.dart' hide Order;
import 'package:injectable/injectable.dart' hide Order;
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_data_source.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource _localDataSource;
  final OrderRemoteDataSource _remoteDataSource;

  OrderRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<Either<Failure, List<Order>>> getOrders() async {
    try {
      final models = await _localDataSource.getOrders();
      models.sort((a, b) => b.date.compareTo(a.date));
      return Right(models);
    } on CacheException {
      return const Left(CacheFailure('Error al cargar los pedidos'));
    }
  }

  @override
  Future<Either<Failure, void>> saveOrder(Order order) async {
    try {
      final model = OrderModel.fromEntity(order);
      await _localDataSource.saveOrder(model);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Error al guardar el pedido'));
    } catch (e) {
      return Left(ServerFailure('Error al crear el pedido: $e'));
    }
  }

  @override
  Future<Either<Failure, Order>> createOrder(
    Order order,
    String customerId,
  ) async {
    try {
      final model = OrderModel.fromEntity(order);

      // Create order in Supabase
      final createdOrder = await _remoteDataSource.createOrder(
        model,
        customerId,
      );

      // Save locally for offline access
      await _localDataSource.saveOrder(createdOrder);
      return Right(createdOrder);
    } on CacheException {
      return const Left(CacheFailure('Error al guardar el pedido'));
    } catch (e) {
      return Left(ServerFailure('Error al crear el pedido: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getOrdersFromServer(
    String customerId,
  ) async {
    try {
      final orders = await _remoteDataSource.getOrders(customerId);
      return Right(orders);
    } catch (e) {
      return Left(ServerFailure('Error al cargar órdenes: $e'));
    }
  }

  @override
  Stream<Order> watchOrderStatus(String orderId) {
    return _remoteDataSource.watchOrderStatus(orderId).cast<Order>();
  }
}
