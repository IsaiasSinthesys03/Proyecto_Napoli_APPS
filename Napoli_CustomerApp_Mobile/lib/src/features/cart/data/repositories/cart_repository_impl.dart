import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../models/cart_item_model.dart';

@LazySingleton(as: CartRepository)
class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource _localDataSource;

  CartRepositoryImpl(this._localDataSource);

  @override
  Future<Either<Failure, List<CartItem>>> getCart() async {
    try {
      final models = await _localDataSource.getCart();
      return Right(models);
    } on CacheException {
      return const Left(CacheFailure('Error al cargar el carrito'));
    }
  }

  @override
  Future<Either<Failure, void>> saveCart(List<CartItem> items) async {
    try {
      final models = items.map((e) => CartItemModel.fromEntity(e)).toList();
      await _localDataSource.saveCart(models);
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Error al guardar el carrito'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      await _localDataSource.clearCart();
      return const Right(null);
    } on CacheException {
      return const Left(CacheFailure('Error al limpiar el carrito'));
    }
  }
}
