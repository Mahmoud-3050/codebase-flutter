import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/get_student_profile_response.dart';
import '../repositories/profile_repo.dart';

class GetStudentProfileUseCase
    extends UseCase<GetStudentProfileResponse, CancellableParams> {
  final ProfileRepository repository;

  GetStudentProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, GetStudentProfileResponse>> call(
    CancellableParams params,
  ) async {
    return await repository.getStudentProfile(params: params);
  }
}
