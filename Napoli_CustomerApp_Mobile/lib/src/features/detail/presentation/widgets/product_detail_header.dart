import 'package:flutter/material.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/safe_image.dart';
import 'package:napoli_app_v1/src/core/core_domain/entities/product.dart';

class ProductDetailHeader extends StatelessWidget {
  final Product product;

  const ProductDetailHeader({super.key, required this.product});

  IconData _getIconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'pizzas':
        return Icons.local_pizza_outlined;
      case 'pastas':
        return Icons.restaurant_menu;
      case 'postres':
        return Icons.cake;
      case 'bebidas':
        return Icons.local_drink_outlined;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: theme.colorScheme.primary,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Material(
          color: theme.colorScheme.surface.withValues(alpha: 0.85),
          shape: const CircleBorder(),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accentBeigeLight, AppColors.surfaceLight],
            ),
          ),
          child: Center(
            child: product.image.isNotEmpty
                ? SafeImage(assetPath: product.image, fit: BoxFit.contain)
                : Icon(
                    _getIconForCategory(product.category),
                    size: 150,
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
          ),
        ),
      ),
    );
  }
}
