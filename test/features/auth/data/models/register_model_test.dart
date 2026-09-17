import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/data/models/register_model.dart';
import 'package:codebase/features/auth/data/models/request_otp_model.dart';
import 'package:codebase/features/auth/data/models/verify_email_model.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';

import '../../fixtures.dart';

void main() {
  test('FR-009 RegisterModel.fromJson maps OTP challenge', () {
    final RegisterModel model = RegisterModel.fromJson(kOtpChallengeJson());
    expect(model.data.purpose, OtpPurpose.verifyEmail);
    expect(model.data.resendAvailableInSeconds, 45);
  });

  test('FR-011 VerifyEmailModel.fromJson maps session', () {
    final VerifyEmailModel model = VerifyEmailModel.fromJson(kSessionJson());
    expect(model.data.accessToken, kAccessToken);
    expect(model.data.user.email, 'ada@example.com');
  });

  test('FR-012 RequestOtpModel.fromJson', () {
    final RequestOtpModel model = RequestOtpModel.fromJson(
      kOtpChallengeJson(resend: 12),
    );
    expect(model.data.resendAvailableInSeconds, 12);
  });
}
