import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/get_company_profile_response.dart';
import '../repositories/profile_repo.dart';

class GetCompanyProfileUseCase
    extends UseCase<GetCompanyProfileResponse, NoParams> {
  final ProfileRepository repository;

  GetCompanyProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, GetCompanyProfileResponse>> call(
    NoParams params,
  ) async {
    return await repository.getCompanyProfile(params: params);
  }
}
