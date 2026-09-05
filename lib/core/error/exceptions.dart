import 'package:equatable/equatable.dart';

import '../api/status_code.dart';
import 'failures.dart';

abstract class AppException extends Equatable implements Exception {
  abstract final String? message;

  const AppException();

  Failure toFailure();

  @override
  List<Object?> get props => <Object?>[message];

  @override
  String toString() {
    return '$message';
  }
}

class ServerException extends AppException {
  @override
  final String? message;
  final int? statusCode;

  const ServerException({this.message, this.statusCode});

  @override
  List<Object?> get props => <Object?>[message, statusCode];

  @override
  Failure toFailure() {
    return ServerFailure(message: message, statusCode: statusCode);
  }
}

class FetchDataException extends AppException {
  @override
  final String? message;

  const FetchDataException({this.message});

  @override
  Failure toFailure() {
    return FetchDataFailure(message: message);
  }
}

class UnauthorizedException extends AppException {
  @override
  final String? message;

  const UnauthorizedException({this.message});

  @override
  Failure toFailure() {
    return UnauthorizedFailure(message: message);
  }
}

class InternetConnectionException extends AppException {
  @override
  final String? message;

  const InternetConnectionException({this.message});

  @override
  Failure toFailure() {
    return NetworkFailure(message: message);
  }
}

class CacheException extends AppException {
  @override
  final String? message;

  const CacheException({this.message});

  @override
  Failure toFailure() {
    return CacheFailure(message: message);
  }
}

class ForbiddenException extends AppException {
  @override
  final String? message;

  const ForbiddenException({this.message});

  @override
  Failure toFailure() {
    return ServerFailure(message: message, statusCode: StatusCode.forbidden);
  }
}

class ConflictException extends AppException {
  @override
  final String? message;

  const ConflictException({this.message});

  @override
  Failure toFailure() {
    return ServerFailure(message: message, statusCode: StatusCode.conflict);
  }
}

class ValidationException extends AppException {
  @override
  final String? message;
  final Map<String, List<String>> fieldErrors;

  const ValidationException({
    this.message,
    this.fieldErrors = const <String, List<String>>{},
  });

  @override
  List<Object?> get props => <Object?>[message, fieldErrors];

  @override
  Failure toFailure() {
    return ValidationFailure(message: message, fieldErrors: fieldErrors);
  }
}

class TooManyRequestsException extends AppException {
  @override
  final String? message;

  const TooManyRequestsException({this.message});

  @override
  Failure toFailure() {
    return ServerFailure(
      message: message,
      statusCode: StatusCode.tooManyRequests,
    );
  }
}

class RequestCancelledException extends AppException {
  @override
  final String? message;

  const RequestCancelledException({this.message});

  @override
  Failure toFailure() {
    return CancelledFailure(message: message);
  }
}
