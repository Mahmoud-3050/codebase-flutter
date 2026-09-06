import '../../../../core/utils/extensions.dart';
import '../../domain/entities/change_student_password_response.dart';

class ChangeStudentPasswordModel extends ChangeStudentPasswordResponse {
  const ChangeStudentPasswordModel({
    required super.status,
    required super.message,
  });

  factory ChangeStudentPasswordModel.fromJson(Map<String, dynamic> json) =>
      ChangeStudentPasswordModel(
        status: (json['status'] as Object?).toStringOrEmpty(),
        message: (json['message'] as Object?).toStringOrEmpty(),
      );
}
