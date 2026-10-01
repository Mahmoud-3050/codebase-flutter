import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/features/auth/data/models/login_model.dart';
import 'package:codebase/features/auth/domain/entities/login_outcome.dart';

import '../../fixtures.dart';

void main() {
  test('FR-015 LoginModel session branch', () {
    final LoginModel model = LoginModel.fromJson(kSessionJson());
    expect(model.data, isA<LoginSucceeded>());
  });

  test('FR-017 LoginModel email_verification_required branch', () {
    final LoginModel model = LoginModel.fromJson(
      kOtpChallengeJson()
        ..['data'] = <String, dynamic>{
          ...kOtpChallengeJson()['data'] as Map<String, dynamic>,
          'outcome': 'email_verification_required',
        },
    );
    expect(model.data, isA<LoginNeedsEmailVerification>());
  });

  test('FR-015 LoginModel accepts a session that omits outcome', () {
    final Map<String, dynamic> json = kSessionJson();
    (json['data'] as Map<String, dynamic>).remove('outcome');
    final LoginModel model = LoginModel.fromJson(json);
    expect(model.data, isA<LoginSucceeded>());
    expect((model.data as LoginSucceeded).session.accessToken, kAccessToken);
  });

  test('FR-017 LoginModel rejects an unknown outcome without a token', () {
    expect(
      () => LoginModel.fromJson(<String, dynamic>{
        'status': 'success',
        'message': 'ok',
        'data': <String, dynamic>{'outcome': 'verify_later'},
      }),
      throwsA(isA<ServerException>()),
    );
  });
}
