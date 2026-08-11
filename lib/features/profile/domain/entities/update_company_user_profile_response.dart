import 'package:equatable/equatable.dart';

class UpdateCompanyUserProfileResponse extends Equatable{
  final String status;
  final String message;
  final Company data;

  const UpdateCompanyUserProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => <Object?>[
    status,
    message,
    data,
  ];
}


class Company extends Equatable {
  final int id;
  final String firstName;
  final String secondName;
  final String lastName;
  final String fullName;
  final String dialingCode;
  final String phone;
  final String email;
  final String birthdate;
  final int cityId;
  final String verifiedAt;
  final String companyName;
  final String industry;
  final String about;
  final dynamic logo;
  final String description;
  final String createdAt;
  final dynamic accessToken;

  const Company({
    required this.id,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.fullName,
    required this.dialingCode,
    required this.phone,
    required this.email,
    required this.birthdate,
    required this.cityId,
    required this.verifiedAt,
    required this.companyName,
    required this.industry,
    required this.about,
    required this.logo,
    required this.description,
    required this.createdAt,
    required this.accessToken,
  });

  Company copyWith({
    int? id,
    String? firstName,
    String? secondName,
    String? lastName,
    String? fullName,
    String? dialingCode,
    String? phone,
    String? email,
    String? birthdate,
    int? cityId,
    String? verifiedAt,
    String? companyName,
    String? industry,
    String? about,
    dynamic logo,
    String? description,
    String? createdAt,
    dynamic accessToken,
  }) {
    return Company(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      dialingCode: dialingCode ?? this.dialingCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthdate: birthdate ?? this.birthdate,
      cityId: cityId ?? this.cityId,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      companyName: companyName ?? this.companyName,
      industry: industry ?? this.industry,
      about: about ?? this.about,
      logo: logo ?? this.logo,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      accessToken: accessToken ?? this.accessToken,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    firstName,
    secondName,
    lastName,
    fullName,
    dialingCode,
    phone,
    email,
    birthdate,
    cityId,
    verifiedAt,
    companyName,
    industry,
    about,
    logo,
    description,
    createdAt,
    accessToken,
  ];

}


