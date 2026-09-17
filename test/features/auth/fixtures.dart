import 'package:codebase/core/services/local_storage/interfaces/local_storage_interface.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/auth_user.dart';
import 'package:codebase/features/auth/domain/entities/otp_challenge.dart';
import 'package:codebase/features/auth/domain/entities/registration_draft.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';


const String kValidOtpCode = '123456';
const String kInvalidOtpCode = '12ab';
const String kAccessToken = 'access-token-value';

final DateTime kCreatedAt = DateTime.fromMillisecondsSinceEpoch(
  1705276800000,
  isUtc: true,
);

final AuthUser kVerifiedUser = AuthUser(
  id: 1,
  fullName: 'Ada Lovelace',
  email: 'ada@example.com',
  dialingCode: '+966',
  phone: '500000000',
  isEmailVerified: true,
  isPhoneVerified: true,
  createdAt: kCreatedAt,
  avatarUrl: 'https://example.com/a.png',
);

final AuthUser kUnverifiedUser = AuthUser(
  id: 2,
  fullName: 'Un Verified',
  email: 'unverified@example.com',
  dialingCode: '+966',
  phone: '511111111',
  isEmailVerified: false,
  isPhoneVerified: false,
  createdAt: kCreatedAt,
);

final AuthSession kSession = AuthSession(
  accessToken: kAccessToken,
  user: kVerifiedUser,
);

const OtpChallenge kEmailChallenge = OtpChallenge(
  purpose: OtpPurpose.verifyEmail,
  maskedDestination: 'a***@example.com',
  expiresInSeconds: 600,
  resendAvailableInSeconds: 45,
);

const OtpChallenge kPhoneChallenge = OtpChallenge(
  purpose: OtpPurpose.phoneSignIn,
  maskedDestination: '+966*****000',
  expiresInSeconds: 600,
  resendAvailableInSeconds: 30,
);

const RegistrationDraft kPhoneDraft = RegistrationDraft(
  registrationToken: 'reg-token-phone',
  source: RegistrationSource.phone,
  verifiedDialingCode: '+966',
  verifiedPhone: '500000000',
);

const RegistrationDraft kGoogleDraft = RegistrationDraft(
  registrationToken: 'reg-token-google',
  source: RegistrationSource.google,
  verifiedEmail: 'ada@gmail.com',
  suggestedFullName: 'Ada Lovelace',
);

const RegistrationDraft kAppleDraft = RegistrationDraft(
  registrationToken: 'reg-token-apple',
  source: RegistrationSource.apple,
  verifiedEmail: 'relay@privaterelay.appleid.com',
  suggestedFullName: 'Ada',
);

Map<String, dynamic> kUserJson({bool verified = true}) => <String, dynamic>{
  'id': verified ? 1 : 2,
  'full_name': verified ? 'Ada Lovelace' : 'Un Verified',
  'email': verified ? 'ada@example.com' : 'unverified@example.com',
  'dialing_code': '+966',
  'phone': verified ? '500000000' : '511111111',
  'email_verified': verified,
  'phone_verified': verified,
  'created_at': '2024-01-15T00:00:00.000Z',
  'avatar_url': verified ? 'https://example.com/a.png' : null,
};

Map<String, dynamic> kSessionJson() => <String, dynamic>{
  'status': 'success',
  'message': 'ok',
  'data': <String, dynamic>{
    'outcome': 'session',
    'access_token': kAccessToken,
    'user': kUserJson(),
  },
};

Map<String, dynamic> kOtpChallengeJson({
  String purpose = 'verify_email',
  int resend = 45,
}) => <String, dynamic>{
  'status': 'success',
  'message': 'ok',
  'data': <String, dynamic>{
    'purpose': purpose,
    'masked_destination': 'a***@example.com',
    'expires_in_seconds': 600,
    'resend_available_in_seconds': resend,
  },
};

Map<String, dynamic> kRegistrationRequiredJson(RegistrationSource source) {
  return <String, dynamic>{
    'status': 'success',
    'message': 'ok',
    'data': <String, dynamic>{
      'outcome': 'registration_required',
      'registration_token': 'reg-token-${source.wireName}',
      'source': source.wireName,
      'verified_email': source == RegistrationSource.phone
          ? null
          : (source == RegistrationSource.apple
                ? 'relay@privaterelay.appleid.com'
                : 'ada@gmail.com'),
      'verified_dialing_code': source == RegistrationSource.phone
          ? '+966'
          : null,
      'verified_phone': source == RegistrationSource.phone ? '500000000' : null,
      'suggested_full_name': source == RegistrationSource.phone ? null : 'Ada',
    },
  };
}

/// 1x1 PNG (89 bytes) — JPEG/PNG and well under 2 MB.
const List<int> kSmallPngBytes = <int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
  0x42,
  0x60,
  0x82,
];

class MemoryStorage implements LocalStorageInterface {
  MemoryStorage([this.value]);

  String? value;
  bool failSave = false;
  bool failRemove = false;

  @override
  Future<String?> read({String? key}) async => value;

  @override
  Future<bool> save({required String value, String? key}) async {
    if (failSave) {
      return false;
    }
    this.value = value;
    return true;
  }

  @override
  Future<bool> remove({String? key}) async {
    if (failRemove) {
      return false;
    }
    value = null;
    return true;
  }
}
