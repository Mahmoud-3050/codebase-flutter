import 'package:either/either.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

abstract class UseCase<T, P extends Params> {
  Future<Either<Failure, T>> call(P params);
}

/// Shared request handle for every use case.
///
/// [cancellation] is opaque in domain (no Dio). Data sources accept a Dio
/// [CancelToken] instance.
abstract class Params extends Equatable {
  const Params();

  abstract final Object? cancellation;

  Map<String, dynamic> toJson() => const <String, dynamic>{};
}

class NoParams extends Params {
  const NoParams({this.cancellation});

  @override
  final Object? cancellation;

  @override
  List<Object?> get props => const <Object?>[];
}
