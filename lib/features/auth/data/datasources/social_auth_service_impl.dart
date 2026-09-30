import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/enums/social_provider.dart';
import 'social_auth_service.dart';

class SocialAuthServiceImpl implements SocialAuthService {
  SocialAuthServiceImpl({this.googleServerClientId, GoogleSignIn? googleSignIn})
    : _googleSignIn = googleSignIn;

  final String? googleServerClientId;
  final GoogleSignIn? _googleSignIn;
  bool _googleInitialized = false;

  @override
  Future<SocialCredential> authorize(SocialProvider provider) {
    return switch (provider) {
      SocialProvider.google => _authorizeGoogle(),
      SocialProvider.apple => _authorizeApple(),
    };
  }

  Future<SocialCredential> _authorizeGoogle() async {
    try {
      final GoogleSignIn google = _googleSignIn ?? GoogleSignIn.instance;
      if (!_googleInitialized) {
        await google.initialize(serverClientId: googleServerClientId);
        _googleInitialized = true;
      }
      final GoogleSignInAccount account = await google.authenticate();
      final String? idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ServerException();
      }
      return SocialCredential(
        provider: SocialProvider.google,
        idToken: idToken,
        email: account.email,
        fullName: account.displayName,
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const SocialSignInCancelledException();
      }
      throw ServerException(message: error.description);
    }
  }

  Future<SocialCredential> _authorizeApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
            scopes: <AppleIDAuthorizationScopes>[
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
      final String? idToken = credential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw const ServerException();
      }
      final String fullName = <String?>[
        credential.givenName,
        credential.familyName,
      ].whereType<String>().where((String part) => part.isNotEmpty).join(' ');
      return SocialCredential(
        provider: SocialProvider.apple,
        idToken: idToken,
        authorizationCode: credential.authorizationCode,
        email: credential.email,
        fullName: fullName.isEmpty ? null : fullName,
      );
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const SocialSignInCancelledException();
      }
      throw ServerException(message: error.message);
    }
  }
}
