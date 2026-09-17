import '../../../../core/utils/extensions.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/enums/otp_purpose.dart';
import '../../domain/enums/registration_source.dart';
import 'auth_user_model.dart';

AuthSession parseAuthSession(Map<String, dynamic> json) {
  final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
  return AuthSession(
    accessToken: _readAccessToken(payload, json),
    user: AuthUserModel.fromJson(
      payload['user'] is Map<String, dynamic>
          ? payload['user'] as Map<String, dynamic>
          : payload,
    ),
  );
}

String _readAccessToken(
  Map<String, dynamic> payload,
  Map<String, dynamic> json,
) {
  final Object? nested =
      payload['access_token'] ?? payload['accessToken'] ?? payload['token'];
  if (nested != null && nested.toString().isNotEmpty) {
    return nested.toString();
  }
  final Object? root =
      json['access_token'] ?? json['accessToken'] ?? json['token'];
  return root.toStringOrEmpty();
}

OtpChallenge parseOtpChallenge(Map<String, dynamic> json) {
  final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
  return OtpChallenge(
    purpose: OtpPurpose.fromWireName(
      (payload['purpose'] as Object?).toStringOrEmpty(),
    ),
    maskedDestination: (payload['masked_destination'] as Object?)
        .toStringOrEmpty(),
    expiresInSeconds: (payload['expires_in_seconds'] as Object?).toIntOrZero(),
    resendAvailableInSeconds:
        (payload['resend_available_in_seconds'] as Object?).toIntOrZero(),
  );
}

RegistrationDraft parseRegistrationDraft(Map<String, dynamic> json) {
  final Map<String, dynamic> payload = json['data'] is Map<String, dynamic>
      ? json['data'] as Map<String, dynamic>
      : json;
  return RegistrationDraft(
    registrationToken: (payload['registration_token'] as Object?)
        .toStringOrEmpty(),
    source: RegistrationSource.fromWireName(
      (payload['source'] as Object?).toStringOrEmpty(),
    ),
    verifiedEmail: _optionalString(payload['verified_email']),
    verifiedDialingCode: _optionalString(payload['verified_dialing_code']),
    verifiedPhone: _optionalString(payload['verified_phone']),
    suggestedFullName: _optionalString(payload['suggested_full_name']),
  );
}

String envelopeStatus(Map<String, dynamic> json) =>
    (json['status'] as Object?).toStringOrEmpty();

String envelopeMessage(Map<String, dynamic> json) =>
    (json['message'] as Object?).toStringOrEmpty();

String? _optionalString(Object? value) {
  if (value == null) {
    return null;
  }
  final String text = value.toString();
  return text.isEmpty ? null : text;
}
