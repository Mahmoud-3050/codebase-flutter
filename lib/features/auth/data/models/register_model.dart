import '../../domain/entities/register_response.dart';
import 'auth_json.dart';

class RegisterModel extends RegisterResponse {
  const RegisterModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
    status: envelopeStatus(json),
    message: envelopeMessage(json),
    data: parseOtpChallenge(json),
  );
}
