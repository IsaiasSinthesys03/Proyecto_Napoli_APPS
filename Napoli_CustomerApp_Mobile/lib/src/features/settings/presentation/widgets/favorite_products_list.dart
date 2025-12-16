import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/features/cart/domain/entities/cart_item.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:napoli_app_v1/src/core/core_domain/repositories/product_repository.dart';
import 'package:napoli_app_v1/src/features/settings/domain/entities/order_history.dart';

class FavoriteProductsList extends StatelessWidget {
  final List<OrderHistory> orders;

  const FavoriteProductsList({super.key, required this.orders});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calcular productos más frecuentes agrupando por ID
    // Map<ProductId, {count: int, name: String}>
    final productStats = <String, Map<String, dynamic>>{};

    for (final order in orders) {
      if (order.status == OrderHistoryStatus.delivered) {
        for (final item in order.items) {
          if (item.productId.isEmpty) continue;

          final current =
              productStats[item.productId] ?? {'count': 0, 'name': item.name};
          productStats[item.productId] = {
            'count': (current['count'] as int) + item.quantity,
            'name': item.name, // Keep latest name
          };
        }
      }
    }

    final sortedProducts = productStats.entries.toList()
      ..sort(
        (a, b) => (b.value['count'] as int).compareTo(a.value['count'] as int),
      );

    if (sortedProducts.isEmpty) {
      return Center(
        child: Text(
          'No has realizado pedidos entregados aún.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    // Tomar top 5
    final topProducts = sortedProducts.take(5).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tus productos favoritos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...topProducts.map((entry) {
            final productId = entry.key;
            final data = entry.value;
            final name = data['name'] as String;
            final count = data['count'] as int;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.local_pizza,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pedido $count veces',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_shopping_cart),
                    onPressed: () async {
                      // Add to cart logic
                      try {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Agregando al carrito...'),
                            duration: Duration(milliseconds: 500),
                          ),
                        );

                        final repo = getIt<ProductRepository>();
                        // Fetch fresh product data to get price/options
                        // This assumes GetProductByIdUseCase or repo method exists
                        // The repo interface usually returns Result<Product> or Product?
                        final result = await repo.getById(productId);

                        result.fold(
                          (failure) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: ${failure.message}'),
                                ),
                              );
                            }
                          },
                          (product) {
                            if (context.mounted) {
                              if (product == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Producto no disponible'),
                                  ),
                                );
                                return;
                              }

                              // Convert to CartItem.
                              // Note: This adds base product without previous extras customization
                              // Ideally we'd prompt for extras or use defaults.
                              final cartItem = CartItem(
                                id: product.id,
                                name: product.name,
                                image: product.image,
                                price: product
                                    .price, // In cents? CartItem expects cents? Product entity usually has display price if double, or cents if int.
                                // Let's check entities. CartItem uses int (cents) usually?
                                // Product entity uses int (cents).
                                quantity: 1,
                                selectedExtras: [],
                              );

                              context.read<CartCubit>().addItem(cartItem);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Producto agregado'),
                                ),
                              );
                            }
                          },
                        );
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text('Error: $e')));
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
