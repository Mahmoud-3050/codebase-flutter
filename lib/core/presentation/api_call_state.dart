import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Shared cubit / API view-state. Prefer this over a status enum so each
/// variant can carry payload (`data`, `message`) and `switch` is exhaustive.
sealed class ApiCallState<T> extends Equatable {
  const ApiCallState();

  bool get isHolding => this is ApiCallHolding<T>;
  bool get isLoading => this is ApiCallLoading<T>;
  bool get isSuccess => this is ApiCallSuccess<T>;
  bool get isError => this is ApiCallError<T>;
  bool get isEmpty => this is ApiCallEmpty<T>;
  bool get isRefresh => this is ApiCallRefresh<T>;
  bool get isPagination => this is ApiCallPagination<T>;

  @override
  List<Object?> get props => const <Object?>[];
}

final class ApiCallHolding<T> extends ApiCallState<T> {
  const ApiCallHolding();
}

final class ApiCallLoading<T> extends ApiCallState<T> {
  const ApiCallLoading();
}

final class ApiCallSuccess<T> extends ApiCallState<T> {
  final T data;

  const ApiCallSuccess({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class ApiCallError<T> extends ApiCallState<T> {
  final String message;
  final Map<String, List<String>> fieldErrors;

  const ApiCallError({
    required this.message,
    this.fieldErrors = const <String, List<String>>{},
  });

  factory ApiCallError.fromFailure(
    Failure failure, {
    required String fallbackMessage,
  }) {
    return ApiCallError<T>(
      message: failure.message ?? fallbackMessage,
      fieldErrors: failure.fieldErrors,
    );
  }

  bool get hasFieldErrors =>
      fieldErrors.values.any((List<String> messages) => messages.isNotEmpty);

  @override
  List<Object?> get props => <Object?>[message, fieldErrors];
}

final class ApiCallEmpty<T> extends ApiCallState<T> {
  const ApiCallEmpty();
}

final class ApiCallRefresh<T> extends ApiCallState<T> {
  final T? data;

  const ApiCallRefresh({this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class ApiCallPagination<T> extends ApiCallState<T> {
  final T data;

  const ApiCallPagination({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}
