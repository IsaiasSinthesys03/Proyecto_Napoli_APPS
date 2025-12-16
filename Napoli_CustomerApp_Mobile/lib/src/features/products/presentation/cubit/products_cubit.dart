import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../../../core/core_domain/entities/product.dart';

import '../../domain/usecases/get_product_detail_usecase.dart';
import '../../domain/usecases/get_business_lunch_usecase.dart';
import '../../../../core/usecases/usecase.dart';
import 'products_state.dart';
import '../../domain/usecases/get_categories_usecase.dart';

@lazySingleton
class ProductsCubit extends Cubit<ProductsState> {
  final GetProductsUseCase _getProductsUseCase;
  final GetProductDetailUseCase _getProductDetailUseCase;
  final GetBusinessLunchUseCase _getBusinessLunchUseCase;
  final GetCategoriesUseCase _getCategoriesUseCase;

  ProductsCubit(
    this._getProductsUseCase,
    this._getProductDetailUseCase,
    this._getBusinessLunchUseCase,
    this._getCategoriesUseCase,
  ) : super(const ProductsInitial());

  Future<void> loadHomeProducts() async {
    emit(const ProductsLoading());

    // We can't simply Future.wait because different return types in Either make it messy with generics list
    // But we can still parallelize conceptually or just await sequentially for simplicity and type safety

    final featuredResult = await _getProductsUseCase(NoParams());
    if (featuredResult.isLeft()) {
      emit(ProductsError(featuredResult.getLeft().toNullable()!.message));
      return;
    }

    final businessLunchResult = await _getBusinessLunchUseCase(NoParams());
    if (businessLunchResult.isLeft()) {
      emit(ProductsError(businessLunchResult.getLeft().toNullable()!.message));
      return;
    }

    final categoriesResult = await _getCategoriesUseCase(NoParams());
    // Categories are optional, failure shouldn't block the app, but let's log/handle
    // If it fails, we get empty list.
    final categories = categoriesResult.getRight().toNullable() ?? [];

    emit(
      HomeProductsLoaded(
        featured: featuredResult.getRight().toNullable()!,
        businessLunch: businessLunchResult.getRight().toNullable()!,
        categories: categories,
      ),
    );
  }

  Future<void> loadFeaturedProducts() async {
    emit(const ProductsLoading());

    final result = await _getProductsUseCase(NoParams());

    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> loadProductDetail(String id) async {
    emit(const ProductsLoading());

    final result = await _getProductDetailUseCase(
      GetProductDetailParams(id: id),
    );

    result.fold((failure) => emit(ProductsError(failure.message)), (product) {
      if (product != null) {
        emit(ProductDetailLoaded(product));
      } else {
        emit(const ProductsError('Producto no encontrado'));
      }
    });
  }

  void filterProducts({String? category, String? query}) {
    if (state is! HomeProductsLoaded) return;
    final currentState = state as HomeProductsLoaded;

    final selectedCategory = category ?? currentState.selectedCategory;
    final searchQuery = query ?? currentState.searchQuery;

    List<Product> filterList(List<Product> items) {
      var filtered = items;
      if (selectedCategory != 'all') {
        // Internal ID check
        filtered = filtered
            .where((p) => p.category == selectedCategory)
            .toList();
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        filtered = filtered.where((p) {
          final name = p.name.toLowerCase();
          final cat = p.category.toLowerCase();
          return name.contains(q) || cat.contains(q);
        }).toList();
      }
      return filtered;
    }

    emit(
      currentState.copyWith(
        filteredFeatured: filterList(currentState.featured),
        filteredBusinessLunch: filterList(currentState.businessLunch),
        selectedCategory: selectedCategory,
        searchQuery: searchQuery,
      ),
    );
  }
}
