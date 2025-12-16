import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/core_domain/entities/product.dart';
import '../../../../core/core_domain/repositories/product_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@lazySingleton
class GetBusinessLunchUseCase implements UseCase<List<Product>, NoParams> {
  final ProductRepository _repository;

  GetBusinessLunchUseCase(this._repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await _repository.fetchBusinessLunch();
  }
}
