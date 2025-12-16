import 'package:flutter/material.dart';
import '../../../../../../l10n/arb/app_localizations.dart';

class EmptyOrdersState extends StatelessWidget {
  final String selectedFilter;

  const EmptyOrdersState({super.key, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    String message;
    IconData icon;

    switch (selectedFilter) {
      case 'in_progress':
        message = l10n.noOrdersInProgress;
        icon = Icons.hourglass_empty;
        break;
      case 'cancelled':
        message = l10n.noOrdersCancelled;
        icon = Icons.cancel_outlined;
        break;
      case 'delivered':
        message = l10n.noOrdersDelivered;
        icon = Icons.check_circle_outline;
        break;
      default:
        message = l10n.noOrders;
        icon = Icons.shopping_bag_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.ordersEmptyDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
