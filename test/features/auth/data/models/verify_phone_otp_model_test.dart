import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/data/models/verify_phone_otp_model.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';

import '../../fixtures.dart';

void main() {
  test('FR-021 VerifyPhoneOtpModel session branch', () {
    final VerifyPhoneOtpModel model = VerifyPhoneOtpModel.fromJson(
      kSessionJson(),
    );
    expect(model.data, isA<AuthSessionEstablished>());
  });

  test('FR-023 VerifyPhoneOtpModel registration_required phone draft', () {
    final VerifyPhoneOtpModel model = VerifyPhoneOtpModel.fromJson(
      kRegistrationRequiredJson(RegistrationSource.phone),
    );
    expect(model.data, isA<AuthRegistrationRequired>());
    final AuthRegistrationRequired required =
        model.data! as AuthRegistrationRequired;
    expect(required.draft.source, RegistrationSource.phone);
    expect(required.draft.verifiedPhone, '500000000');
  });

  test('FR-021 VerifyPhoneOtpModel empty data and unknown outcome', () {
    expect(
      VerifyPhoneOtpModel.fromJson(<String, dynamic>{
        'status': 'success',
        'message': 'ok',
        'data': <String, dynamic>{},
      }).data,
      isNull,
    );
    expect(
      VerifyPhoneOtpModel.fromJson(<String, dynamic>{
        'status': 'success',
        'message': 'ok',
        'data': <String, dynamic>{'outcome': 'ack'},
      }).data,
      isNull,
    );
  });
}
