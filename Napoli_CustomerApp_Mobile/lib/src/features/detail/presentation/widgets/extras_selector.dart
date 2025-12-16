import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/core/core_domain/entities/product.dart';
import 'package:napoli_app_v1/src/core/services/restaurant_config_service.dart';
import 'package:napoli_app_v1/src/di.dart';

class ExtrasSelector extends StatelessWidget {
  final List<ProductExtra> availableExtras;
  final List<ProductExtra> selectedExtras;
  final ValueChanged<ProductExtra> onExtraToggle;

  const ExtrasSelector({
    super.key,
    required this.availableExtras,
    required this.selectedExtras,
    required this.onExtraToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (availableExtras.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.customizeOrder,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        ...availableExtras.map((extra) {
          final isSelected = selectedExtras.contains(extra);
          return CheckboxListTile(
            title: Text(extra.name, style: theme.textTheme.bodyLarge),
            subtitle: Text(
              '+${getIt<RestaurantConfigService>().formatPriceSync(extra.price)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
            value: isSelected,
            activeColor: theme.colorScheme.primary,
            onChanged: (value) => onExtraToggle(extra),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }
}
