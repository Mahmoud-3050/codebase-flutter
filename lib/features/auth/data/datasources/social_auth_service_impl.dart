import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/enums/social_provider.dart';
import 'social_auth_service.dart';

typedef AppleCredentialLoader =
    Future<AuthorizationCredentialAppleID> Function(
      List<AppleIDAuthorizationScopes> scopes,
    );

typedef GoogleClientInitializer = Future<void> Function(String serverClientId);

typedef GoogleAuthenticator = Future<SocialCredential> Function();

class SocialAuthServiceImpl implements SocialAuthService {
  SocialAuthServiceImpl({
    this.googleServerClientId,
    GoogleSignIn? googleSignIn,
    AppleCredentialLoader? loadAppleCredential,
    GoogleClientInitializer? initializeGoogle,
    GoogleAuthenticator? authenticateGoogle,
  }) : _googleSignIn = googleSignIn,
       _loadAppleCredential = loadAppleCredential ?? _defaultAppleCredential,
       _initializeGoogle = initializeGoogle,
       _authenticateGoogle = authenticateGoogle;

  final String? googleServerClientId;
  final GoogleSignIn? _googleSignIn;
  final AppleCredentialLoader _loadAppleCredential;
  final GoogleClientInitializer? _initializeGoogle;
  final GoogleAuthenticator? _authenticateGoogle;
  Future<void>? _googleInitialization;

  static Future<AuthorizationCredentialAppleID> _defaultAppleCredential(
    List<AppleIDAuthorizationScopes> scopes,
  ) {
    return SignInWithApple.getAppleIDCredential(scopes: scopes);
  }

  @override
  Future<SocialCredential> authorize(SocialProvider provider) {
    return switch (provider) {
      SocialProvider.google => _authorizeGoogle(),
      SocialProvider.apple => _authorizeApple(),
    };
  }

  Future<SocialCredential> _authorizeGoogle() async {
    final String? serverClientId = googleServerClientId?.trim();
    if (serverClientId == null || serverClientId.isEmpty) {
      throw const ServerException();
    }
    try {
      await _ensureGoogleInitialized(serverClientId);
      final GoogleAuthenticator? authenticateGoogle = _authenticateGoogle;
      if (authenticateGoogle != null) {
        return authenticateGoogle();
      }
      final GoogleSignIn google = _googleSignIn ?? GoogleSignIn.instance;
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

  /// One in-flight [GoogleSignIn.initialize]. A second authorize waits on the
  /// same future. A failed attempt clears it so the next call can retry.
  Future<void> _ensureGoogleInitialized(String serverClientId) {
    final Future<void>? inFlight = _googleInitialization;
    if (inFlight != null) {
      return inFlight;
    }
    final Future<void> pending = _initializeGoogleClient(serverClientId);
    _googleInitialization = pending;
    unawaited(
      pending.then<void>(
        (_) {},
        onError: (Object _, StackTrace _) {
          if (identical(_googleInitialization, pending)) {
            _googleInitialization = null;
          }
        },
      ),
    );
    return pending;
  }

  Future<void> _initializeGoogleClient(String serverClientId) async {
    final GoogleClientInitializer? initializeGoogle = _initializeGoogle;
    if (initializeGoogle != null) {
      await initializeGoogle(serverClientId);
      return;
    }
    final GoogleSignIn google = _googleSignIn ?? GoogleSignIn.instance;
    await google.initialize(serverClientId: serverClientId);
  }

  Future<SocialCredential> _authorizeApple() async {
    try {
      final AuthorizationCredentialAppleID credential =
          await _loadAppleCredential(<AppleIDAuthorizationScopes>[
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ]);
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
