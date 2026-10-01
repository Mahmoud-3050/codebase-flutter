import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/features/auth/data/models/social_sign_in_model.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';

import '../../fixtures.dart';

void main() {
  test('FR-030 SocialSignInModel session branch', () {
    final SocialSignInModel model = SocialSignInModel.fromJson(kSessionJson());
    expect(model.data, isA<AuthSessionEstablished>());
  });

  test('FR-031 SocialSignInModel google-source draft', () {
    final SocialSignInModel model = SocialSignInModel.fromJson(
      kRegistrationRequiredJson(RegistrationSource.google),
    );
    expect(model.data, isA<AuthRegistrationRequired>());
    expect(
      (model.data as AuthRegistrationRequired).draft.source,
      RegistrationSource.google,
    );
  });

  test('FR-034 SocialSignInModel apple-source draft with relay email', () {
    final SocialSignInModel model = SocialSignInModel.fromJson(
      kRegistrationRequiredJson(RegistrationSource.apple),
    );
    final AuthRegistrationRequired required =
        model.data as AuthRegistrationRequired;
    expect(required.draft.source, RegistrationSource.apple);
    expect(required.draft.verifiedEmail, 'relay@privaterelay.appleid.com');
  });

  test(
    'FR-030 SocialSignInModel rejects a session outcome with an empty token',
    () {
      expect(
        () => SocialSignInModel.fromJson(<String, dynamic>{
          'status': 'success',
          'message': 'ok',
          'data': <String, dynamic>{'outcome': 'session', 'user': kUserJson()},
        }),
        throwsA(isA<ServerException>()),
      );
    },
  );

  test('FR-030 SocialSignInModel accepts a token when outcome is omitted', () {
    final Map<String, dynamic> json = kSessionJson();
    (json['data'] as Map<String, dynamic>).remove('outcome');
    final SocialSignInModel model = SocialSignInModel.fromJson(json);
    final AuthSessionEstablished established =
        model.data as AuthSessionEstablished;
    expect(established.session, isA<AuthSession>());
    expect(established.session.accessToken, kAccessToken);
  });
}
