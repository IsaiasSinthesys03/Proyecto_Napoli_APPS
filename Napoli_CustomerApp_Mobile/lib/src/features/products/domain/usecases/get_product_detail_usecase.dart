import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/core_domain/entities/product.dart';
import '../../../../core/core_domain/repositories/product_repository.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';

@lazySingleton
class GetProductDetailUseCase
    implements UseCase<Product?, GetProductDetailParams> {
  final ProductRepository _repository;

  GetProductDetailUseCase(this._repository);

  @override
  Future<Either<Failure, Product?>> call(GetProductDetailParams params) async {
    return await _repository.getById(params.id);
  }
}

class GetProductDetailParams extends Equatable {
  final String id;

  const GetProductDetailParams({required this.id});

  @override
  List<Object?> get props => [id];
}
