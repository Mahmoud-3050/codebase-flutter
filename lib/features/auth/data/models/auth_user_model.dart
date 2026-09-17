import '../../../../core/utils/extensions.dart';
import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.dialingCode,
    required super.phone,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.createdAt,
    super.avatarUrl,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final String? avatar = json['avatar_url']?.toString();
    return AuthUserModel(
      id: (json['id'] as Object?).toIntOrZero(),
      fullName: (json['full_name'] as Object?).toStringOrEmpty(),
      email: (json['email'] as Object?).toStringOrEmpty(),
      dialingCode: (json['dialing_code'] as Object?).toStringOrEmpty(),
      phone: (json['phone'] as Object?).toStringOrEmpty(),
      avatarUrl: avatar == null || avatar.isEmpty ? null : avatar,
      isEmailVerified: json['email_verified'] == true,
      isPhoneVerified: json['phone_verified'] == true,
      createdAt:
          DateTime.tryParse(
            (json['created_at'] as Object?).toStringOrEmpty(),
          ) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    );
  }
}
