import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/data/models/social_sign_in_model.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
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
}
