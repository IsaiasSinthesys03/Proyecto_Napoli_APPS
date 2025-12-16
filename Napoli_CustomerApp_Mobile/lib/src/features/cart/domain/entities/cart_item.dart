import 'package:equatable/equatable.dart';
import '../../../../core/core_domain/entities/product.dart';

class CartItem extends Equatable {
  final String id;
  final String name;
  final String image;
  final int price;
  final int quantity;
  final List<ProductExtra> selectedExtras;
  final String? specialInstructions;

  const CartItem({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    this.quantity = 1,
    this.selectedExtras = const [],
    this.specialInstructions,
  });

  int get totalPrice {
    int extrasTotal = selectedExtras.fold(0, (sum, extra) => sum + extra.price);
    return (price + extrasTotal) * quantity;
  }

  CartItem copyWith({
    String? id,
    String? name,
    String? image,
    int? price,
    int? quantity,
    List<ProductExtra>? selectedExtras,
    String? specialInstructions,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      selectedExtras: selectedExtras ?? this.selectedExtras,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    image,
    price,
    quantity,
    selectedExtras,
    specialInstructions,
  ];
}
