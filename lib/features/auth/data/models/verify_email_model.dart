import '../../domain/entities/verify_email_response.dart';
import 'auth_json.dart';

class VerifyEmailModel extends VerifyEmailResponse {
  const VerifyEmailModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory VerifyEmailModel.fromJson(Map<String, dynamic> json) =>
      VerifyEmailModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: parseAuthSession(json),
      );
}
