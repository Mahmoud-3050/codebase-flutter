import '../../../../core/utils/extensions.dart';
import '../../domain/entities/login_outcome.dart';
import '../../domain/entities/login_response.dart';
import 'auth_json.dart';

class LoginModel extends LoginResponse {
  const LoginModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final String outcome = (payload['outcome'] as Object?).toStringOrEmpty();
    if (outcome == 'email_verification_required') {
      return LoginModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: LoginNeedsEmailVerification(parseOtpChallenge(json)),
      );
    }
    return LoginModel(
      status: envelopeStatus(json),
      message: envelopeMessage(json),
      data: LoginSucceeded(parseAuthSession(json)),
    );
  }
}
