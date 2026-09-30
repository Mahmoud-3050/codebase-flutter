import 'package:equatable/equatable.dart';

import '../../domain/enums/social_provider.dart';

final class SocialCredential extends Equatable {
  const SocialCredential({
    required this.provider,
    required this.idToken,
    this.authorizationCode,
    this.fullName,
    this.email,
  });

  final SocialProvider provider;
  final String idToken;
  final String? authorizationCode;
  final String? fullName;
  final String? email;

  @override
  List<Object?> get props => <Object?>[
    provider,
    idToken,
    authorizationCode,
    fullName,
    email,
  ];
}

abstract interface class SocialAuthService {
  Future<SocialCredential> authorize(SocialProvider provider);
}
