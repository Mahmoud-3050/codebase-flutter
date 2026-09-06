import '../../../../core/utils/extensions.dart';
import '../../domain/entities/update_company_user_profile_response.dart';

class UpdateCompanyUserProfileModel extends UpdateCompanyUserProfileResponse {
  const UpdateCompanyUserProfileModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory UpdateCompanyUserProfileModel.fromJson(Map<String, dynamic> json) =>
      UpdateCompanyUserProfileModel(
        status: (json['status'] as Object?).toStringOrEmpty(),
        message: (json['message'] as Object?).toStringOrEmpty(),
        data: CompanyModel.fromJson(json['data']),
      );
}

class CompanyModel extends Company {
  const CompanyModel({
    required super.id,
    required super.firstName,
    required super.secondName,
    required super.lastName,
    required super.fullName,
    required super.dialingCode,
    required super.phone,
    required super.email,
    required super.birthdate,
    required super.cityId,
    required super.verifiedAt,
    required super.companyName,
    required super.industry,
    required super.about,
    required super.logo,
    required super.description,
    required super.createdAt,
    required super.accessToken,
  });

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
    id: (json['id'] as Object?).toIntOrZero(),
    firstName: (json['first_name'] as Object?).toStringOrEmpty(),
    secondName: (json['second_name'] as Object?).toStringOrEmpty(),
    lastName: (json['last_name'] as Object?).toStringOrEmpty(),
    fullName: (json['full_name'] as Object?).toStringOrEmpty(),
    dialingCode: (json['dialing_code'] as Object?).toStringOrEmpty(),
    phone: (json['phone'] as Object?).toStringOrEmpty(),
    email: (json['email'] as Object?).toStringOrEmpty(),
    birthdate: (json['birthdate'] as Object?).toStringOrEmpty(),
    cityId: (json['city_id'] as Object?).toIntOrZero(),
    verifiedAt: (json['verified_at'] as Object?).toStringOrEmpty(),
    companyName: (json['company_name'] as Object?).toStringOrEmpty(),
    industry: (json['industry'] as Object?).toStringOrEmpty(),
    about: (json['about'] as Object?).toStringOrEmpty(),
    logo: (json['logo'] as Object?).toStringOrEmpty(),
    description: (json['description'] as Object?).toStringOrEmpty(),
    createdAt: (json['created_at'] as Object?).toStringOrEmpty(),
    accessToken: (json['access_token'] as Object?).toStringOrEmpty(),
  );
}
