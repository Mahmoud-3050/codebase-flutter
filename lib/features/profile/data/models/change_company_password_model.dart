import '../../../../core/utils/extensions.dart';
import '../../domain/entities/change_company_password_response.dart';

class ChangeCompanyPasswordModel extends ChangeCompanyPasswordResponse {
  const ChangeCompanyPasswordModel({
    required super.status,
    required super.message,
  });

  factory ChangeCompanyPasswordModel.fromJson(Map<String, dynamic> json) =>
      ChangeCompanyPasswordModel(
        status: (json['status'] as Object?).toStringOrEmpty(),
        message: (json['message'] as Object?).toStringOrEmpty(),
      );
}
