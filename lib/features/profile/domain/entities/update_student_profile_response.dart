import 'package:equatable/equatable.dart';

class UpdateStudentProfileResponse extends Equatable {
  final String status;
  final String message;
  final Student data;

  const UpdateStudentProfileResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  @override
  List<Object?> get props => <Object?>[status, message, data];
}

class Student extends Equatable {
  final int id;
  final String firstName;
  final String secondName;
  final String lastName;
  final String fullName;
  final String dialingCode;
  final String phone;
  final dynamic email;
  final String birthdate;
  final int cityId;
  final String institute;
  final String major;
  final String graduationDate;
  final int degreeId;
  final String gpaFile;
  final String cvFile;
  final String image;
  final String createdAt;
  final String verifiedAt;
  final dynamic accessToken;

  const Student({
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
    required this.institute,
    required this.major,
    required this.graduationDate,
    required this.degreeId,
    required this.gpaFile,
    required this.cvFile,
    required this.image,
    required this.createdAt,
    required this.verifiedAt,
    required this.accessToken,
  });

  Student copyWith({
    int? id,
    String? firstName,
    String? secondName,
    String? lastName,
    String? fullName,
    String? dialingCode,
    String? phone,
    dynamic email,
    String? birthdate,
    int? cityId,
    String? institute,
    String? major,
    String? graduationDate,
    int? degreeId,
    String? gpaFile,
    String? cvFile,
    String? image,
    String? createdAt,
    String? verifiedAt,
    dynamic accessToken,
  }) {
    return Student(
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
      institute: institute ?? this.institute,
      major: major ?? this.major,
      graduationDate: graduationDate ?? this.graduationDate,
      degreeId: degreeId ?? this.degreeId,
      gpaFile: gpaFile ?? this.gpaFile,
      cvFile: cvFile ?? this.cvFile,
      image: image ?? this.image,
      createdAt: createdAt ?? this.createdAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
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
    institute,
    major,
    graduationDate,
    degreeId,
    gpaFile,
    cvFile,
    image,
    createdAt,
    verifiedAt,
    accessToken,
  ];
}
