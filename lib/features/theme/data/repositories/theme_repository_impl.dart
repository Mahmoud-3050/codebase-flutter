import 'package:either/either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/log_utils.dart';
import '../../../../core/utils/values/strings.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource themeLocalDataSource;

  ThemeRepositoryImpl({required this.themeLocalDataSource});

  Future<Either<Failure, T>> _guard<T>(
    Future<T> Function() call,
    String operation,
  ) async {
    try {
      final T result = await call();
      return Right<Failure, T>(result);
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

  @override
  Future<Either<Failure, void>> changeTheme({required Themes theme}) =>
      _guard(
        () => themeLocalDataSource.changeTheme(theme: theme),
        'changeTheme',
      );

  @override
  Future<Either<Failure, Themes>> getSavedTheme() => _guard(
        () => themeLocalDataSource.getSavedTheme(),
        'getSavedTheme',
      );
}
