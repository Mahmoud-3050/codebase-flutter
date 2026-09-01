import '../../domain/entities/update_company_user_profile_response.dart';

class UpdateCompanyUserProfileModel extends UpdateCompanyUserProfileResponse {
  const UpdateCompanyUserProfileModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory UpdateCompanyUserProfileModel.fromJson(Map<String, dynamic> json) =>
      UpdateCompanyUserProfileModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
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
    id: json['id'] != null
        ? num.tryParse(json['id'].toString())?.toInt() ?? 0
        : 0,
    firstName: json['first_name'] ?? '',
    secondName: json['second_name'] ?? '',
    lastName: json['last_name'] ?? '',
    fullName: json['full_name'] ?? '',
    dialingCode: json['dialing_code'] ?? '',
    phone: json['phone'] ?? '',
    email: json['email'] ?? '',
    birthdate: json['birthdate'] ?? '',
    cityId: json['city_id'] != null
        ? num.tryParse(json['city_id'].toString())?.toInt() ?? 0
        : 0,
    verifiedAt: json['verified_at'] ?? '',
    companyName: json['company_name'] ?? '',
    industry: json['industry'] ?? '',
    about: json['about'] ?? '',
    logo: json['logo'] ?? '',
    description: json['description'] ?? '',
    createdAt: json['created_at'] ?? '',
    accessToken: json['access_token'] ?? '',
  );
}
