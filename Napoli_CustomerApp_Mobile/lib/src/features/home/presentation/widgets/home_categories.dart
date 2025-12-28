import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/features/products/presentation/cubit/products_cubit.dart';
import '../../../../core/core_domain/entities/category.dart';

class HomeCategories extends StatelessWidget {
  final String selectedCategory;
  final List<Category> categories;

  const HomeCategories({
    super.key,
    required this.selectedCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Add "All" category for filtering (internal id = 'all', display via l10n)
    final allCategories = [
      Category(id: 'all', name: 'all'), // Internal identifier
      ...categories,
    ];

    return SizedBox(
      height: 64,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemCount: allCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = allCategories[index];
          // Use localized 'Todos' for display when id is 'all'
          final label = category.id == 'all' ? l10n.catAll : category.name;
          final selected = category.name == selectedCategory;

          return GestureDetector(
            onTap: () => context.read<ProductsCubit>().filterProducts(
              category: category.name,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  if (selected)
                    BoxShadow(
                      color: theme.shadowColor.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color: selected
                      ? AppColors.white
                      : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                child: Text(label),
              ),
            ),
          );
        },
      ),
    );
  }
}
