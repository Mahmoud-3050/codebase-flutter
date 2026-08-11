import 'package:either/either.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';
import '../../../../core/utils/log_utils.dart';
import '../../domain/repositories/theme_repository.dart';
import '../datasources/theme_local_data_source.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  final ThemeLocalDataSource themeLocalDataSource;

  ThemeRepositoryImpl({required this.themeLocalDataSource});

  @override
  Future<Either<Failure, void>> changeTheme({required Themes theme}) async {
    try {
      final result = await themeLocalDataSource.changeTheme(theme: theme);
      return Right(result);
    } on AppException catch (error) {
      Log.e('[changeTheme] [${error.runtimeType.toString()}] ---- ${error.message}');
      return Left<Failure, bool>(error.toFailure());
    }
  }

  @override
  Future<Either<Failure, Themes>> getSavedTheme() async {
    try {
      final languageCode = await themeLocalDataSource.getSavedTheme();
      return Right(languageCode);
    } on AppException catch (error) {
      Log.e('[getSavedTheme] [${error.runtimeType.toString()}] ---- ${error.message}');
      return Left<Failure, Themes>(error.toFailure());
    }
  }
}
