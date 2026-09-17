import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/logout_response.dart';
import '../repositories/auth_repo.dart';

class LogoutUseCase extends UseCase<LogoutResponse, NoParams> {
  LogoutUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, LogoutResponse>> call(NoParams params) {
    return repository.logout(params: params);
  }
}
