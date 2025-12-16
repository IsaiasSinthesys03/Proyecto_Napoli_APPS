import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/pressable_scale.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/product_card.dart';
import 'package:napoli_app_v1/src/core/core_domain/entities/product.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/di.dart';

class HomeRecommendations extends StatelessWidget {
  final List<Product> filteredFeatured;

  const HomeRecommendations({super.key, required this.filteredFeatured});

  @override
  Widget build(BuildContext context) {
    // Hide section entirely when no featured products
    if (filteredFeatured.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n.recommendations,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: filteredFeatured.length,
            itemBuilder: (context, index) {
              final p = filteredFeatured[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 380 + (index * 70)),
                builder: (context, val, child) {
                  return Opacity(
                    opacity: val,
                    child: Transform.translate(
                      offset: Offset(0, (1 - val) * 12),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PressableScale(
                    child: GestureDetector(
                      onTap: () => context.push('/product/${p.id}'),
                      child: ProductCard(
                        title: p.name,
                        category: p.category,
                        price: getIt<RestaurantConfigService>().formatPriceSync(
                          p.price,
                        ),
                        imagePath: p.image,
                        onTap: () => context.push('/product/${p.id}'),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
