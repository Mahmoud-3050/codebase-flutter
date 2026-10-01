import 'package:flutter_bloc/flutter_bloc.dart';

part 'verified_phone_states.dart';

class VerifiedPhoneCubit extends Cubit<VerifiedPhoneState> {
  VerifiedPhoneCubit() : super(const PhoneNotVerified());

  void fMarkVerified({required String dialingCode, required String phone}) {
    emit(PhoneVerified(dialingCode: dialingCode, phone: phone));
  }
}
