import '../../../../core/utils/extensions.dart';
import '../../domain/entities/auth_outcome.dart';
import '../../domain/entities/social_sign_in_response.dart';
import 'auth_json.dart';

class SocialSignInModel extends SocialSignInResponse {
  const SocialSignInModel({
    required super.status,
    required super.message,
    required super.data,
  });

  factory SocialSignInModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final String outcome = (payload['outcome'] as Object?).toStringOrEmpty();
    if (outcome == 'registration_required') {
      return SocialSignInModel(
        status: envelopeStatus(json),
        message: envelopeMessage(json),
        data: AuthRegistrationRequired(parseRegistrationDraft(json)),
      );
    }
    return SocialSignInModel(
      status: envelopeStatus(json),
      message: envelopeMessage(json),
      data: AuthSessionEstablished(parseAuthSession(json)),
    );
  }
}
