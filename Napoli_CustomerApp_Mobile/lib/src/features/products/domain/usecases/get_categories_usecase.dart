import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/core_domain/entities/category.dart';
import '../../../../core/core_domain/repositories/product_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@lazySingleton
class GetCategoriesUseCase implements UseCase<List<Category>, NoParams> {
  final ProductRepository _repository;

  GetCategoriesUseCase(this._repository);

  @override
  Future<Either<Failure, List<Category>>> call(NoParams params) async {
    return _repository.fetchCategories();
  }
}
