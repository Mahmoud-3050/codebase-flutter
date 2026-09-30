import '../../domain/entities/complete_registration_response.dart';
import 'auth_json.dart';

class CompleteRegistrationModel extends CompleteRegistrationResponse {
  const CompleteRegistrationModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory CompleteRegistrationModel.fromJson(Map<String, dynamic> json) =>
      CompleteRegistrationModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: parseAuthSession(json),
      );
}
