import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/get_company_profile_response.dart';
import '../repositories/profile_repo.dart';

class GetCompanyProfileUseCase
    extends UseCase<GetCompanyProfileResponse, Params> {
  GetCompanyProfileUseCase({required this.repository});

  final ProfileRepository repository;

  @override
  Future<Either<Failure, GetCompanyProfileResponse>> call(Params params) async {
    return await repository.getCompanyProfile(params: params);
  }
}
