import '../../domain/entities/logout_response.dart';
import 'auth_json.dart';

class LogoutModel extends LogoutResponse {
  const LogoutModel({required super.status, required super.message});

  factory LogoutModel.fromJson(Map<String, dynamic> json) =>
      LogoutModel(status: envelopeStatus(json), message: envelopeMessage(json));
}
