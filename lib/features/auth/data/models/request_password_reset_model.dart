import '../../domain/entities/request_password_reset_response.dart';
import 'auth_json.dart';

class RequestPasswordResetModel extends RequestPasswordResetResponse {
  const RequestPasswordResetModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory RequestPasswordResetModel.fromJson(Map<String, dynamic> json) =>
      RequestPasswordResetModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: parseOtpChallenge(json),
      );
}
