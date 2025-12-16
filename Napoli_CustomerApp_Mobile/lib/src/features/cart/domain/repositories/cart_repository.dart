import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItem>>> getCart();
  Future<Either<Failure, void>> saveCart(List<CartItem> items);
  Future<Either<Failure, void>> clearCart();
}
