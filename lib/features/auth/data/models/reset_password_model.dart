import '../../domain/entities/reset_password_response.dart';
import 'auth_json.dart';

class ResetPasswordModel extends ResetPasswordResponse {
  const ResetPasswordModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory ResetPasswordModel.fromJson(Map<String, dynamic> json) =>
      ResetPasswordModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: parseAuthSession(json),
      );
}
