import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/get_cart_usecase.dart';
import '../../domain/usecases/save_cart_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../../coupons/domain/usecases/get_coupon_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'cart_state.dart';

@lazySingleton
class CartCubit extends Cubit<CartState> {
  final GetCartUseCase _getCartUseCase;
  final SaveCartUseCase _saveCartUseCase;
  final ClearCartUseCase _clearCartUseCase;
  final GetCouponUseCase _getCouponUseCase;

  CartCubit(
    this._getCartUseCase,
    this._saveCartUseCase,
    this._clearCartUseCase,
    this._getCouponUseCase,
  ) : super(const CartState());

  Future<void> loadCart() async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _getCartUseCase(NoParams());

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (items) => emit(state.copyWith(items: items, isLoading: false)),
    );
  }

  Future<void> addItem(CartItem item) async {
    final updatedItems = [...state.items, item];
    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  Future<void> removeItem(String id) async {
    final updatedItems = state.items.where((item) => item.id != id).toList();
    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  Future<void> updateQuantity(int index, int newQuantity) async {
    if (index < 0 || index >= state.items.length) return;

    if (newQuantity <= 0) {
      await removeItem(state.items[index].id);
      return;
    }

    final updatedItems = List<CartItem>.from(state.items);
    updatedItems[index] = updatedItems[index].copyWith(quantity: newQuantity);
    emit(state.copyWith(items: updatedItems));
    await _saveCart(updatedItems);
  }

  Future<String?> applyCoupon(String code) async {
    final result = await _getCouponUseCase(GetCouponParams(code: code));

    return result.fold((failure) => failure.message, (coupon) {
      if (coupon != null) {
        emit(state.copyWith(appliedCoupon: coupon));
        return null; // Success
      } else {
        return 'Cupón no válido';
      }
    });
  }

  void removeCoupon() {
    emit(state.copyWith(clearCoupon: true));
  }

  Future<void> clearCart() async {
    emit(state.copyWith(isLoading: true));

    final result = await _clearCartUseCase(NoParams());

    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (_) => emit(const CartState()),
    );
  }

  Future<void> _saveCart(List<CartItem> items) async {
    final result = await _saveCartUseCase(SaveCartParams(items: items));

    result.fold(
      (failure) => emit(state.copyWith(error: failure.message)),
      (_) => {}, // Success, state already updated
    );
  }
}
