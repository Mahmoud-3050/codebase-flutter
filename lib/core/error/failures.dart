import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  abstract final String? message;

  const Failure();

  @override
  List<Object?> get props => <Object?>[message];
}

class ServerFailure extends Failure {
  @override
  final String? message;
  final int? statusCode;

  const ServerFailure({this.message, this.statusCode});

  @override
  List<Object?> get props => <Object?>[message, statusCode];
}

class UnauthorizedFailure extends Failure {
  @override
  final String? message;

  const UnauthorizedFailure({this.message});
}

class CacheFailure extends Failure {
  @override
  final String? message;

  const CacheFailure({this.message});
}

class NetworkFailure extends Failure {
  @override
  final String? message;

  const NetworkFailure({this.message});
}

class FetchDataFailure extends Failure {
  @override
  final String? message;

  const FetchDataFailure({this.message});
}

class CancelledFailure extends Failure {
  @override
  final String? message;

  const CancelledFailure({this.message});
}

class ValidationFailure extends Failure {
  @override
  final String? message;
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure({
    this.message,
    this.fieldErrors = const <String, List<String>>{},
  });

  @override
  List<Object?> get props => <Object?>[message, fieldErrors];
}
