import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/domain/usecases/request_phone_otp_usecase.dart';

void main() {
  test('FR-019 RequestPhoneOtpParams.toJson', () {
    expect(
      const RequestPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
      ).toJson(),
      <String, dynamic>{
        'dialing_code': '+966',
        'phone': '500000000',
        'purpose': 'phone_sign_in',
      },
    );
  });

  test('FR-033 RequestPhoneOtpParams.toJson verify_phone', () {
    expect(
      const RequestPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        purpose: OtpPurpose.verifyPhone,
      ).toJson(),
      <String, dynamic>{
        'dialing_code': '+966',
        'phone': '500000000',
        'purpose': 'verify_phone',
      },
    );
  });
}
