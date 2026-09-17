import '../../../../core/utils/extensions.dart';
import '../../domain/entities/auth_outcome.dart';
import '../../domain/entities/verify_phone_otp_response.dart';
import 'auth_json.dart';

class VerifyPhoneOtpModel extends VerifyPhoneOtpResponse {
  const VerifyPhoneOtpModel({
    required super.status,
    required super.message,
    super.data,
  });

  factory VerifyPhoneOtpModel.fromJson(Map<String, dynamic> json) {
    final Object? rawData = json['data'];
    if (rawData is! Map<String, dynamic> || rawData.isEmpty) {
      return VerifyPhoneOtpModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
      );
    }
    final String outcome = (rawData['outcome'] as Object?).toStringOrEmpty();
    if (outcome == 'registration_required') {
      return VerifyPhoneOtpModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: AuthRegistrationRequired(parseRegistrationDraft(json)),
      );
    }
    if (outcome == 'session' || rawData.containsKey('access_token')) {
      return VerifyPhoneOtpModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: AuthSessionEstablished(parseAuthSession(json)),
      );
    }
    return VerifyPhoneOtpModel(
      status: envelopeStatus(json),
      message: envelopeMessage(json),
    );
  }
}
