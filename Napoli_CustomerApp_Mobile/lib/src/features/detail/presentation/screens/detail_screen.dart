import 'package:flutter/material.dart';
import 'package:napoli_app_v1/l10n/arb/app_localizations.dart';
import 'package:napoli_app_v1/src/core/core_ui/theme.dart';
import 'package:napoli_app_v1/src/di.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:napoli_app_v1/src/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/widgets/add_to_cart_bottom_bar.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/widgets/extras_selector.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/widgets/product_detail_header.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/widgets/product_info_section.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/widgets/quantity_selector.dart';
import 'package:napoli_app_v1/src/features/detail/presentation/widgets/special_instructions_input.dart';
import 'package:napoli_app_v1/src/features/products/presentation/cubit/product_detail_cubit.dart';
import 'package:napoli_app_v1/src/core/core_domain/entities/product.dart';
import 'package:napoli_app_v1/src/features/cart/domain/entities/cart_item.dart';

class DetailScreen extends StatefulWidget {
  final int? index; // kept for compatibility
  final String? productId;
  const DetailScreen({super.key, this.index, this.productId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _quantity = 1;
  final List<ProductExtra> _selectedExtras = [];
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  int _calculateTotalPrice(Product product) {
    int extrasTotal = _selectedExtras.fold(
      0,
      (sum, extra) => sum + extra.price,
    );
    return (product.price + extrasTotal) * _quantity;
  }

  void _addToCart(Product product) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    context.read<CartCubit>().addItem(
      CartItem(
        id: id,
        name: product.name,
        image: product.image,
        price: product.price,
        quantity: _quantity,
        selectedExtras: List.from(_selectedExtras),
        specialInstructions: _instructionsController.text.isEmpty
            ? null
            : _instructionsController.text,
      ),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!.addedToCart,
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        backgroundColor: AppColors.primaryGreen,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<CartCubit>()),
        BlocProvider(
          create: (context) {
            final cubit = getIt<ProductDetailCubit>();
            if (widget.productId != null) {
              cubit.loadProduct(widget.productId!);
            }
            return cubit;
          },
        ),
      ],
      child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return Scaffold(
              backgroundColor: theme.colorScheme.surface,
              body: const Center(child: CircularProgressIndicator()),
            );
          } else if (state is ProductDetailError) {
            return Scaffold(
              backgroundColor: theme.colorScheme.surface,
              body: Center(child: Text('Error: ${state.message}')),
            );
          } else if (state is ProductDetailLoaded) {
            final product = state.product;
            return Scaffold(
              backgroundColor: theme.colorScheme.surface,
              body: CustomScrollView(
                slivers: [
                  ProductDetailHeader(product: product),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProductInfoSection(product: product),
                          const SizedBox(height: 30),
                          QuantitySelector(
                            quantity: _quantity,
                            onIncrement: () => setState(() => _quantity++),
                            onDecrement: _quantity > 1
                                ? () => setState(() => _quantity--)
                                : () {},
                          ),
                          const SizedBox(height: 30),
                          if (product.availableExtras.isNotEmpty)
                            ExtrasSelector(
                              availableExtras: product.availableExtras,
                              selectedExtras: _selectedExtras,
                              onExtraToggle: (extra) {
                                setState(() {
                                  if (_selectedExtras.contains(extra)) {
                                    _selectedExtras.remove(extra);
                                  } else {
                                    _selectedExtras.add(extra);
                                  }
                                });
                              },
                            ),
                          const SizedBox(height: 20),
                          SpecialInstructionsInput(
                            controller: _instructionsController,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              bottomSheet: AddToCartBottomBar(
                totalPrice: _calculateTotalPrice(product),
                onAddToCart: () => _addToCart(product),
              ),
            );
          }
          // Default case (Initial or null product)
          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            body: Center(child: Text(l10n.productNotFound)),
          );
        },
      ),
    );
  }
}
