import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/enums.dart';

abstract class ThemeRepository {
  Future<Either<Failure, void>> changeTheme({required Themes theme});
  Future<Either<Failure, Themes>> getSavedTheme();
}
