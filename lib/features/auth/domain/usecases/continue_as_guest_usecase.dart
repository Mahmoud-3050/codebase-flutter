import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repo.dart';

class ContinueAsGuestUseCase extends UseCase<void, NoParams> {
  ContinueAsGuestUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.continueAsGuest(params: params);
  }
}
