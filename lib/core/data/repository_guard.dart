import 'package:either/either.dart';

import '../../config/language/strings.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../utils/log_utils.dart';

/// Maps data-source exceptions to [Either] for every repository implementation.
mixin RepositoryGuard {
  Future<Either<Failure, T>> guard<T>(
    Future<T> Function() call,
    String operation,
  ) async {
    try {
      final T response = await call();
      return Right<Failure, T>(response);
    } on AppException catch (error) {
      Log.e('[$operation] [${error.runtimeType}] ---- ${error.message}');
      return Left<Failure, T>(error.toFailure());
    } on Object catch (error, stackTrace) {
      Log.e('[$operation] [${error.runtimeType}] ---- $error\n$stackTrace');
      return Left<Failure, T>(
        ServerFailure(message: Strings.pleaseTryAgainLater),
      );
    }
  }
}
