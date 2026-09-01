import 'package:equatable/equatable.dart';
import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/update_company_profile_response.dart';
import '../repositories/profile_repo.dart';

class UpdateCompanyProfileUseCase
    extends UseCase<UpdateCompanyProfileResponse, UpdateCompanyProfileParams> {
  final ProfileRepository repository;

  UpdateCompanyProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, UpdateCompanyProfileResponse>> call(
    UpdateCompanyProfileParams params,
  ) async {
    return await repository.updateCompanyProfile(params: params);
  }
}

class UpdateCompanyProfileParams extends Equatable {
  final String? companyName;
  final String? industry;
  final String? about;
  final String? logo;
  final String? description;

  const UpdateCompanyProfileParams({
    required this.companyName,
    required this.industry,
    required this.about,
    required this.logo,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (companyName != null) {
      map['company_name'] = companyName;
    }
    if (industry != null) {
      map['industry'] = industry;
    }
    if (about != null) {
      map['about'] = about;
    }
    if (logo != null) {
      map['logo'] = logo;
    }
    if (description != null) {
      map['description'] = description;
    }
    return map;
  }

  @override
  List<Object?> get props => <Object?>[
    companyName,
    industry,
    about,
    logo,
    description,
  ];
}
