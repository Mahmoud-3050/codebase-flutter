import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/registration_draft.dart';
import '../repositories/auth_repo.dart';

class ReadRegistrationDraftUseCase
    extends UseCase<RegistrationDraft?, NoParams> {
  ReadRegistrationDraftUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, RegistrationDraft?>> call(NoParams params) {
    return repository.readRegistrationDraft(params: params);
  }
}
