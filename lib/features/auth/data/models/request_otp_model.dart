import '../../domain/entities/request_otp_response.dart';
import 'auth_json.dart';

class RequestOtpModel extends RequestOtpResponse {
  const RequestOtpModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory RequestOtpModel.fromJson(Map<String, dynamic> json) =>
      RequestOtpModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: parseOtpChallenge(json),
      );
}
