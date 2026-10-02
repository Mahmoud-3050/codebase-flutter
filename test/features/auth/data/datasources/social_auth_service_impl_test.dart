import 'dart:async';

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

  const SocialCredential googleCredential = SocialCredential(
    provider: SocialProvider.google,
    idToken: 'google-id-token',
  );

  test('concurrent Google authorize initializes the client once', () async {
    var starts = 0;
    final Completer<void> gate = Completer<void>();
    final SocialAuthServiceImpl service = SocialAuthServiceImpl(
      googleServerClientId: 'client-id',
      initializeGoogle: (String serverClientId) {
        expect(serverClientId, 'client-id');
        starts++;
        return gate.future;
      },
      authenticateGoogle: () async => googleCredential,
    );
    final Future<SocialCredential> first = service.authorize(
      SocialProvider.google,
    );
    final Future<SocialCredential> second = service.authorize(
      SocialProvider.google,
    );
    expect(starts, 1);
    gate.complete();
    final List<SocialCredential> credentials = await Future.wait(
      <Future<SocialCredential>>[first, second],
    );
    expect(credentials, <SocialCredential>[googleCredential, googleCredential]);
  });

  test('Google initialize retries after a failure', () async {
    var starts = 0;
    final SocialAuthServiceImpl service = SocialAuthServiceImpl(
      googleServerClientId: 'client-id',
      initializeGoogle: (String _) async {
        starts++;
        if (starts == 1) {
          throw Exception('init failed');
        }
      },
      authenticateGoogle: () async => googleCredential,
    );
    await expectLater(
      service.authorize(SocialProvider.google),
      throwsA(isA<Exception>()),
    );
    final SocialCredential credential = await service.authorize(
      SocialProvider.google,
    );
    expect(starts, 2);
    expect(credential.idToken, 'google-id-token');
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
