import 'package:flutter/material.dart';
import '../../../../../../l10n/arb/app_localizations.dart';

class PurchaseHistoryFilters extends StatelessWidget {
  final String selectedFilter;
  final List<String> filters;
  final ValueChanged<String> onFilterSelected;

  const PurchaseHistoryFilters({
    super.key,
    required this.selectedFilter,
    required this.filters,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = filter == selectedFilter;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getFilterName(context, filter)),
              selected: isSelected,
              onSelected: (selected) => onFilterSelected(filter),
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
              checkmarkColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              side: BorderSide(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.dividerColor.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getFilterName(BuildContext context, String filter) {
    final l10n = AppLocalizations.of(context)!;
    switch (filter) {
      case 'all':
        return l10n.filterAll;
      case 'delivered':
        return l10n.filterDelivered;
      case 'in_progress':
        return l10n.filterInProgress;
      case 'cancelled':
        return l10n.filterCancelled;
      default:
        return filter;
    }
  }
}
