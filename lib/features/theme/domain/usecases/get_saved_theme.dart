import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../repositories/theme_repository.dart';

class GetSavedThemeUseCase implements UseCase<Themes, NoParams> {
  final ThemeRepository repository;

  GetSavedThemeUseCase({required this.repository});

  @override
  Future<Either<Failure, Themes>> call(NoParams params) async =>
      await repository.getSavedTheme();
}
