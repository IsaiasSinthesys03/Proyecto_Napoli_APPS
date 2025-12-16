import 'package:equatable/equatable.dart';

/// Base class for all failures in the application.
/// Using Equatable to make comparisons easier in tests.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Represents a failure from the server or remote API.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// Represents a failure from local cache or storage.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Represents a failure due to lack of internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// Represents a failure in business logic validation.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
