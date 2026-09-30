import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/domain/usecases/verify_phone_otp_usecase.dart';

void main() {
  test('FR-021 VerifyPhoneOtpParams.toJson includes purpose', () {
    expect(
      const VerifyPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        code: '123456',
        purpose: OtpPurpose.verifyPhone,
      ).toJson(),
      <String, dynamic>{
        'dialing_code': '+966',
        'phone': '500000000',
        'code': '123456',
        'purpose': 'verify_phone',
      },
    );
  });
}
