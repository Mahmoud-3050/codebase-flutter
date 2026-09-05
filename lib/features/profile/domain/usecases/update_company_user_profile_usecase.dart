import 'package:equatable/equatable.dart';
import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/update_company_user_profile_response.dart';
import '../repositories/profile_repo.dart';

class UpdateCompanyUserProfileUseCase
    extends
        UseCase<
          UpdateCompanyUserProfileResponse,
          UpdateCompanyUserProfileParams
        > {
  final ProfileRepository repository;

  UpdateCompanyUserProfileUseCase({required this.repository});

  @override
  Future<Either<Failure, UpdateCompanyUserProfileResponse>> call(
    UpdateCompanyUserProfileParams params,
  ) async {
    return await repository.updateCompanyUserProfile(params: params);
  }
}

class UpdateCompanyUserProfileParams extends Equatable {
  final String? firstName;
  final String? secondName;
  final String? lastName;
  final String? fullName;
  final String? dialingCode;
  final String? phone;
  final String? birthdate;
  final int? cityId;
  final String? image;
  final Object? cancellation;

  const UpdateCompanyUserProfileParams({
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.fullName,
    required this.dialingCode,
    required this.phone,
    required this.birthdate,
    required this.cityId,
    required this.image,
    this.cancellation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (firstName != null) {
      map['first_name'] = firstName;
    }
    if (secondName != null) {
      map['second_name'] = secondName;
    }
    if (lastName != null) {
      map['last_name'] = lastName;
    }
    if (fullName != null) {
      map['full_name'] = fullName;
    }
    if (dialingCode != null) {
      map['dialing_code'] = dialingCode;
    }
    if (phone != null) {
      map['phone'] = phone;
    }
    if (birthdate != null) {
      map['birthdate'] = birthdate;
    }
    if (cityId != null) {
      map['city_id'] = cityId;
    }
    if (image != null) {
      map['image'] = image;
    }
    return map;
  }

  @override
  List<Object?> get props => <Object?>[
    firstName,
    secondName,
    lastName,
    fullName,
    dialingCode,
    phone,
    birthdate,
    cityId,
    image,
  ];
}
