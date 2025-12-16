import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/product_list_item.dart';
import 'package:napoli_app_v1/src/core/core_domain/entities/product.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/di.dart';

class HomeMenu extends StatelessWidget {
  final List<Product> filteredBusinessLunch;

  const HomeMenu({super.key, required this.filteredBusinessLunch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final all = filteredBusinessLunch;

    if (all.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                l10n.fullMenu,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            );
          }
          final p = all[index - 1]; // Offset by 1 for title
          return ProductListItem(
            imagePath: p.image,
            title: p.name,
            subtitle: p.category,
            price: getIt<RestaurantConfigService>().formatPriceSync(p.price),
            onTap: () => context.push('/product/${p.id}'),
          );
        },
        childCount: all.length + 1, // +1 for title
      ),
    );
  }
}
