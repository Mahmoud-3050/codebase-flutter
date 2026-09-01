import '../../domain/entities/get_student_profile_response.dart';

class GetStudentProfileModel extends GetStudentProfileResponse {
  const GetStudentProfileModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory GetStudentProfileModel.fromJson(Map<String, dynamic> json) =>
      GetStudentProfileModel(
        status: json['status'] ?? '',
        message: json['message'] ?? '',
        data: StudentModel.fromJson(json['data']),
      );
}

class StudentModel extends Student {
  const StudentModel({
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
    required super.institute,
    required super.major,
    required super.graduationDate,
    required super.degreeId,
    required super.gpaFile,
    required super.cvFile,
    required super.image,
    required super.gpaFilePath,
    required super.cvFilePath,
    required super.imagePath,
    required super.guard,
    required super.createdAt,
    required super.verifiedAt,
    required super.accessToken,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) => StudentModel(
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
    institute: json['institute'] ?? '',
    major: json['major'] ?? '',
    graduationDate: json['graduation_date'] ?? '',
    degreeId: json['degree_id'] != null
        ? num.tryParse(json['degree_id'].toString())?.toInt() ?? 0
        : 0,
    gpaFile: json['gpa_file'] ?? '',
    cvFile: json['cv_file'] ?? '',
    image: json['image'] ?? '',
    gpaFilePath: json['gpa_file_path'] ?? '',
    cvFilePath: json['cv_file_path'] ?? '',
    imagePath: json['image_path'] ?? '',
    guard: json['guard'] ?? '',
    createdAt: json['created_at'] ?? '',
    verifiedAt: json['verified_at'] ?? '',
    accessToken: json['access_token'] ?? '',
  );
}
