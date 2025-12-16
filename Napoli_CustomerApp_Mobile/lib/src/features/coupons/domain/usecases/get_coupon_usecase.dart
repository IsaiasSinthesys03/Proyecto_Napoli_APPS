import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/coupon.dart';
import '../repositories/coupon_repository.dart';

@lazySingleton
class GetCouponUseCase implements UseCase<Coupon?, GetCouponParams> {
  final CouponRepository _repository;

  GetCouponUseCase(this._repository);

  @override
  Future<Either<Failure, Coupon?>> call(GetCouponParams params) async {
    return await _repository.getCoupon(params.code);
  }
}

class GetCouponParams extends Equatable {
  final String code;

  const GetCouponParams({required this.code});

  @override
  List<Object?> get props => [code];
}
