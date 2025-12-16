import 'package:equatable/equatable.dart';

abstract class BusinessStatusState extends Equatable {
  const BusinessStatusState();

  @override
  List<Object> get props => [];
}

class BusinessStatusInitial extends BusinessStatusState {
  const BusinessStatusInitial();
}

class BusinessOpen extends BusinessStatusState {
  const BusinessOpen();
}

class BusinessClosingSoon extends BusinessStatusState {
  final String message;
  const BusinessClosingSoon(this.message);

  @override
  List<Object> get props => [message];
}

class BusinessClosed extends BusinessStatusState {
  final String message;
  final String nextOpeningTime;
  final String schedule;

  const BusinessClosed({
    required this.message,
    required this.nextOpeningTime,
    required this.schedule,
  });

  @override
  List<Object> get props => [message, nextOpeningTime, schedule];
}
