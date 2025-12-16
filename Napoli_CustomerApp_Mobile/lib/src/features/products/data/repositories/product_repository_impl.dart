import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:collection/collection.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/core_domain/entities/product.dart';
import '../../../../core/core_domain/entities/category.dart';
import '../../../../core/core_domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _dataSource;

  ProductRepositoryImpl(this._dataSource);

  @override
  Future<Either<Failure, List<Product>>> fetchFeatured() async {
    try {
      final models = await _dataSource.getProducts();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Error loading featured products from cache'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> fetchBusinessLunch() async {
    try {
      final models = await _dataSource.getProducts();
      // Business logic: reversed list for lunch
      return Right(models.reversed.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Error loading business lunch from cache'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> fetchCategories() async {
    try {
      final models = await _dataSource.getCategories();
      return Right(models.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure('Error loading categories from cache'));
    }
  }

  @override
  Future<Either<Failure, Product?>> getById(String id) async {
    try {
      final models = await _dataSource.getProducts();
      final model = models.firstWhereOrNull((p) => p.id == id);
      return Right(model?.toEntity());
    } catch (e) {
      return Left(CacheFailure('Error loading product from cache'));
    }
  }
}
