import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/get_student_profile_response.dart';
import '../repositories/profile_repo.dart';

class GetStudentProfileUseCase
    extends UseCase<GetStudentProfileResponse, Params> {
  GetStudentProfileUseCase({required this.repository});

  final ProfileRepository repository;

  @override
  Future<Either<Failure, GetStudentProfileResponse>> call(Params params) async {
    return await repository.getStudentProfile(params: params);
  }
}
