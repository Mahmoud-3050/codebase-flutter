import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../repositories/theme_repository.dart';

class ChangeThemeUseCase implements UseCase<void, Themes> {
  final ThemeRepository repository;

  ChangeThemeUseCase({required this.repository});

  @override
  Future<Either<Failure, void>> call(Themes theme) async =>
      await repository.changeTheme(theme: theme);
}
