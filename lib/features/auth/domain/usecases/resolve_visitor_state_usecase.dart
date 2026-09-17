import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../repositories/auth_repo.dart';

class ResolveVisitorStateUseCase extends UseCase<UserType, NoParams> {
  ResolveVisitorStateUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, UserType>> call(NoParams params) {
    return repository.resolveVisitorState(params: params);
  }
}
