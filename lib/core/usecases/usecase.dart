import 'package:either/either.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => <Object?>[];
}

/// Use-case params that can carry a presentation-owned cancel handle.
///
/// The value is opaque in domain (no Dio). Data sources accept a Dio
/// [CancelToken] instance.
class CancellableParams extends Equatable {
  const CancellableParams({this.cancellation});

  final Object? cancellation;

  @override
  List<Object?> get props => const <Object?>[];
}
