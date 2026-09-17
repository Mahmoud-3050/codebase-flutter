import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.dialingCode,
    required this.phone,
    required this.isEmailVerified,
    required this.isPhoneVerified,
    required this.createdAt,
    this.avatarUrl,
  });

  final int id;
  final String fullName;
  final String email;
  final String dialingCode;
  final String phone;
  final String? avatarUrl;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime createdAt;

  @override
  List<Object?> get props => <Object?>[
    id,
    fullName,
    email,
    dialingCode,
    phone,
    avatarUrl,
    isEmailVerified,
    isPhoneVerified,
    createdAt,
  ];
}
