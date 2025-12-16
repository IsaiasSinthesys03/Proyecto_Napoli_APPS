import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/core_domain/entities/product.dart';
import '../../domain/usecases/get_product_detail_usecase.dart';

part 'product_detail_state.dart';

@injectable
class ProductDetailCubit extends Cubit<ProductDetailState> {
  final GetProductDetailUseCase _getProductDetailUseCase;

  ProductDetailCubit(this._getProductDetailUseCase)
    : super(ProductDetailInitial());

  Future<void> loadProduct(String id) async {
    emit(ProductDetailLoading());
    final result = await _getProductDetailUseCase(
      GetProductDetailParams(id: id),
    );
    result.fold((failure) => emit(ProductDetailError(failure.message)), (
      product,
    ) {
      if (product != null) {
        emit(ProductDetailLoaded(product));
      } else {
        emit(const ProductDetailError('Producto no encontrado'));
      }
    });
  }
}
