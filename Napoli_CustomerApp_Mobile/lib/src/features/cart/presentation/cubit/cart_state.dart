import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import '../../../coupons/domain/entities/coupon.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final Coupon? appliedCoupon;
  final bool isLoading;
  final String? error;

  const CartState({
    this.items = const [],
    this.appliedCoupon,
    this.isLoading = false,
    this.error,
  });

  // Delivery fee constant
  static const int _deliveryFee = 50;

  int get subtotal => items.fold(0, (sum, item) => sum + item.totalPrice);

  int get deliveryFee => items.isEmpty ? 0 : _deliveryFee;

  int get discount {
    if (appliedCoupon == null || subtotal == 0) return 0;
    return (subtotal * appliedCoupon!.discountPercentage / 100).round();
  }

  int get total => subtotal + deliveryFee - discount;

  CartState copyWith({
    List<CartItem>? items,
    Coupon? appliedCoupon,
    bool? isLoading,
    String? error,
    bool clearCoupon = false,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [items, appliedCoupon, isLoading, error];
}
