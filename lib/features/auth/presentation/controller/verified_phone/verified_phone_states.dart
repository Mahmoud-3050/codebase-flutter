part of 'verified_phone_cubit.dart';

sealed class VerifiedPhoneState {
  const VerifiedPhoneState();
}

final class PhoneNotVerified extends VerifiedPhoneState {
  const PhoneNotVerified();
}

final class PhoneVerified extends VerifiedPhoneState {
  const PhoneVerified({required this.dialingCode, required this.phone});

  final String dialingCode;
  final String phone;

  bool matches({required String dialingCode, required String phone}) {
    return this.dialingCode == dialingCode && this.phone == phone;
  }
}
