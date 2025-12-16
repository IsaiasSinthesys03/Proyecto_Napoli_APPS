import 'package:equatable/equatable.dart';
import '../../../../core/core_domain/entities/product.dart';
import '../../../../core/core_domain/entities/category.dart';

abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<Product> products;

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

class HomeProductsLoaded extends ProductsState {
  final List<Product> featured;
  final List<Product> businessLunch;
  final List<Category> categories;
  final List<Product> filteredFeatured;
  final List<Product> filteredBusinessLunch;
  final String selectedCategory;
  final String searchQuery;

  const HomeProductsLoaded({
    required this.featured,
    required this.businessLunch,
    this.categories = const [],
    List<Product>? filteredFeatured,
    List<Product>? filteredBusinessLunch,
    this.selectedCategory = 'all', // Internal ID, display uses l10n.catAll
    this.searchQuery = '',
  }) : filteredFeatured = filteredFeatured ?? featured,
       filteredBusinessLunch = filteredBusinessLunch ?? businessLunch;

  HomeProductsLoaded copyWith({
    List<Product>? featured,
    List<Product>? businessLunch,
    List<Category>? categories,
    List<Product>? filteredFeatured,
    List<Product>? filteredBusinessLunch,
    String? selectedCategory,
    String? searchQuery,
  }) {
    return HomeProductsLoaded(
      featured: featured ?? this.featured,
      businessLunch: businessLunch ?? this.businessLunch,
      categories: categories ?? this.categories,
      filteredFeatured: filteredFeatured ?? this.filteredFeatured,
      filteredBusinessLunch:
          filteredBusinessLunch ?? this.filteredBusinessLunch,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    featured,
    businessLunch,
    categories,
    filteredFeatured,
    filteredBusinessLunch,
    selectedCategory,
    searchQuery,
  ];
}

class ProductDetailLoaded extends ProductsState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
