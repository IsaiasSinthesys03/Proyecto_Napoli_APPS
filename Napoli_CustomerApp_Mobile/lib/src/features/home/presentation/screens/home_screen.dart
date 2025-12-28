import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:napoli_app_v1/l10n/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/app_scaffold.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/business_closed_dialog.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/closing_soon_dialog.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/footer.dart';
import 'package:napoli_app_v1/src/core/core_ui/widgets/header.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:napoli_app_v1/src/features/home/presentation/cubit/business_status_cubit.dart';
import 'package:napoli_app_v1/src/features/home/presentation/cubit/business_status_state.dart';
import 'package:napoli_app_v1/src/features/home/presentation/widgets/home_banner.dart';
import 'package:napoli_app_v1/src/features/home/presentation/widgets/home_categories.dart';
import 'package:napoli_app_v1/src/features/home/presentation/widgets/home_menu.dart';
import 'package:napoli_app_v1/src/features/home/presentation/widgets/home_recommendations.dart';
import 'package:napoli_app_v1/src/features/products/presentation/cubit/products_cubit.dart';
import 'package:napoli_app_v1/src/features/products/presentation/cubit/products_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _bannerController;

  @override
  void dispose() {
    _searchController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    // listen to search changes to update UI
    _searchController.addListener(() {
      context.read<ProductsCubit>().filterProducts(
        query: _searchController.text,
      );
    });

    // Mostrar diálogo de horarios al entrar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BusinessStatusCubit>().checkBusinessStatus();
      getIt<ProductsCubit>().loadHomeProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AppScaffold(
      floatingActionButton: ScaleTransition(
        scale: Tween(begin: 0.98, end: 1.02).animate(
          CurvedAnimation(parent: _bannerController, curve: Curves.easeInOut),
        ),
        child: AppFooter(
          onCartTap: () {
            context.push('/cart');
          },
        ),
      ),
      body: BlocProvider.value(
        value: getIt<ProductsCubit>(),
        child: BlocListener<BusinessStatusCubit, BusinessStatusState>(
          listener: (context, state) {
            if (state is BusinessClosed) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => BusinessClosedDialog(
                  nextOpeningTime: state.nextOpeningTime,
                  schedule: state.schedule,
                ),
              );
            } else if (state is BusinessClosingSoon) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const ClosingSoonDialog(),
              );
            }
          },
          child: BlocBuilder<ProductsCubit, ProductsState>(
            builder: (context, state) {
              if (state is ProductsLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is ProductsError) {
                return Center(child: Text('Error: ${state.message}'));
              } else if (state is HomeProductsLoaded) {
                return CustomScrollView(
                  slivers: [
                    // Keep the app header (address) as a top element aligned with existing widgets
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                        child: AppHeader(address: l10n.homeAddress),
                      ),
                    ),

                    // Search field
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.shadowColor.withValues(
                                  alpha: 0.06,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: l10n.searchHint,
                              prefixIcon: Icon(
                                Icons.search,
                                color: theme.colorScheme.primary,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Promo banner
                    const SliverToBoxAdapter(child: HomeBanner()),

                    // Categories horizontal
                    SliverToBoxAdapter(
                      child: HomeCategories(
                        selectedCategory: state.selectedCategory,
                        categories: state.categories,
                      ),
                    ),

                    // Recommendations title and horizontal featured products
                    SliverToBoxAdapter(
                      child: HomeRecommendations(
                        filteredFeatured: state.filteredFeatured,
                      ),
                    ),

                    // Empty state when no products available
                    if (state.filteredFeatured.isEmpty &&
                        state.filteredBusinessLunch.isEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.restaurant_menu,
                                size: 64,
                                color: theme.disabledColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noProductsAvailable,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    (0.7 * 255).round(),
                                  ),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Full menu list with title
                    HomeMenu(
                      filteredBusinessLunch: state.filteredBusinessLunch,
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }
}
