import 'package:flutter_test/flutter_test.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service_impl.dart';
import 'package:codebase/features/auth/domain/enums/social_provider.dart';

void main() {
  test(
    'FR-030 Google authorize fails before the SDK when the client id is missing',
    () {
      final SocialAuthServiceImpl service = SocialAuthServiceImpl();
      expect(
        service.authorize(SocialProvider.google),
        throwsA(isA<ServerException>()),
      );
    },
  );

  SocialAuthServiceImpl appleService(
    Future<AuthorizationCredentialAppleID> Function() load,
  ) {
    return SocialAuthServiceImpl(
      loadAppleCredential: (List<AppleIDAuthorizationScopes> scopes) {
        expect(scopes, contains(AppleIDAuthorizationScopes.email));
        expect(scopes, contains(AppleIDAuthorizationScopes.fullName));
        return load();
      },
    );
  }

  AuthorizationCredentialAppleID credential({
    String? identityToken = 'apple-id-token',
    String? givenName = 'Ada',
    String? familyName = 'Lovelace',
    String? email = 'ada@privaterelay.appleid.com',
  }) {
    return AuthorizationCredentialAppleID(
      userIdentifier: 'user',
      givenName: givenName,
      familyName: familyName,
      authorizationCode: 'auth-code',
      email: email,
      identityToken: identityToken,
      state: null,
    );
  }

  test(
    'FR-034 Apple authorize returns the identity token and full name',
    () async {
      final SocialCredential credentialResult = await appleService(
        () async => credential(),
      ).authorize(SocialProvider.apple);
      expect(credentialResult.provider, SocialProvider.apple);
      expect(credentialResult.idToken, 'apple-id-token');
      expect(credentialResult.authorizationCode, 'auth-code');
      expect(credentialResult.fullName, 'Ada Lovelace');
      expect(credentialResult.email, 'ada@privaterelay.appleid.com');
    },
  );

  test(
    'FR-034a Apple authorize omits a name that Apple did not return',
    () async {
      final SocialCredential credentialResult = await appleService(
        () async => credential(givenName: null, familyName: null),
      ).authorize(SocialProvider.apple);
      expect(credentialResult.fullName, isNull);
    },
  );

  test('FR-030 Apple authorize fails when the identity token is missing', () {
    expect(
      appleService(
        () async => credential(identityToken: ''),
      ).authorize(SocialProvider.apple),
      throwsA(isA<ServerException>()),
    );
  });

  test('FR-035 Apple cancel is not a failed sign-in', () {
    expect(
      appleService(() async {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.canceled,
          message: 'canceled',
        );
      }).authorize(SocialProvider.apple),
      throwsA(isA<SocialSignInCancelledException>()),
    );
  });

  test('FR-035a Apple authorization failure becomes a server error', () {
    expect(
      appleService(() async {
        throw const SignInWithAppleAuthorizationException(
          code: AuthorizationErrorCode.failed,
          message: 'failed',
        );
      }).authorize(SocialProvider.apple),
      throwsA(isA<ServerException>()),
    );
  });
}
