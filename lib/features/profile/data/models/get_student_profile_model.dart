import '../../../../core/utils/extensions.dart';
import '../../domain/entities/get_student_profile_response.dart';

class GetStudentProfileModel extends GetStudentProfileResponse {
  const GetStudentProfileModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory GetStudentProfileModel.fromJson(Map<String, dynamic> json) =>
      GetStudentProfileModel(
        status: (json['status'] as Object?).toStringOrEmpty(),
        message: (json['message'] as Object?).toStringOrEmpty(),
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
    institute: (json['institute'] as Object?).toStringOrEmpty(),
    major: (json['major'] as Object?).toStringOrEmpty(),
    graduationDate: (json['graduation_date'] as Object?).toStringOrEmpty(),
    degreeId: (json['degree_id'] as Object?).toIntOrZero(),
    gpaFile: (json['gpa_file'] as Object?).toStringOrEmpty(),
    cvFile: (json['cv_file'] as Object?).toStringOrEmpty(),
    image: (json['image'] as Object?).toStringOrEmpty(),
    gpaFilePath: (json['gpa_file_path'] as Object?).toStringOrEmpty(),
    cvFilePath: (json['cv_file_path'] as Object?).toStringOrEmpty(),
    imagePath: (json['image_path'] as Object?).toStringOrEmpty(),
    guard: (json['guard'] as Object?).toStringOrEmpty(),
    createdAt: (json['created_at'] as Object?).toStringOrEmpty(),
    verifiedAt: (json['verified_at'] as Object?).toStringOrEmpty(),
    accessToken: (json['access_token'] as Object?).toStringOrEmpty(),
  );
}
