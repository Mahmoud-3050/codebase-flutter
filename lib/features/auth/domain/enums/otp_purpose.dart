enum OtpPurpose {
  verifyEmail(wireName: 'verify_email'),
  phoneSignIn(wireName: 'phone_sign_in'),
  verifyPhone(wireName: 'verify_phone'),
  resetPassword(wireName: 'reset_password');

  const OtpPurpose({required this.wireName});

  final String wireName;

  static OtpPurpose fromWireName(String value) {
    for (final OtpPurpose purpose in OtpPurpose.values) {
      if (purpose.wireName == value) {
        return purpose;
      }
    }
    throw FormatException('Unknown OTP purpose: $value');
  }
}
