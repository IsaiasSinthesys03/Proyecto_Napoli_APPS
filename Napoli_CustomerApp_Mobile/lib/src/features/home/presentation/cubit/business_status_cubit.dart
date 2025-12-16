import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/business_hours.service.dart';
import 'business_status_state.dart';

@injectable
class BusinessStatusCubit extends Cubit<BusinessStatusState> {
  final BusinessHoursService _businessHoursService;

  BusinessStatusCubit(this._businessHoursService)
    : super(const BusinessStatusInitial());

  Future<void> checkBusinessStatus() async {
    final isOpen = await _businessHoursService.isOpen();

    if (!isOpen) {
      final nextOpeningTime = await _businessHoursService.getNextOpeningTime();
      final schedule = await _businessHoursService.getBusinessHoursMessage();

      emit(
        BusinessClosed(
          message: 'Lo sentimos, actualmente no estamos aceptando pedidos.',
          nextOpeningTime: nextOpeningTime,
          schedule: schedule,
        ),
      );
    } else {
      final isClosingSoon = await _businessHoursService.isClosingSoon();
      if (isClosingSoon) {
        emit(
          const BusinessClosingSoon(
            '¡Atención! Estaremos cerrando en breve. Asegúrate de completar tu pedido pronto.',
          ),
        );
      } else {
        emit(const BusinessOpen());
      }
    }
  }
}
