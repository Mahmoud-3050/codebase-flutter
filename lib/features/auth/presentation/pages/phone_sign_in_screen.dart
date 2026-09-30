import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/services/phone_number/phone_validation_service.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../controller/request_phone_otp/request_phone_otp_cubit.dart';
import '../navigation/router.dart';
import '../validators/auth_validators.dart';

class PhoneSignInScreen extends StatefulWidget {
  const PhoneSignInScreen({super.key});

  @override
  State<PhoneSignInScreen> createState() => _PhoneSignInScreenState();
}

class _PhoneSignInScreenState extends State<PhoneSignInScreen> {
  final TextEditingController _phone = TextEditingController();
  String _dialingCode = '+966';
  String _submittedDialingCode = '+966';
  String _submittedPhone = '';

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  void _submit() {
    final PhoneValidationResult parsed = PhoneValidationService()
        .validatePhoneNumber(phoneNumber: _phone.text, phoneCode: _dialingCode);
    if (!parsed.isValidPhone) {
      showAppSnackBar(
        context: context,
        message: Strings.errorValidPhoneNumber,
        type: ToastType.error,
      );
      return;
    }
    _submittedDialingCode = '+${parsed.phoneCode}';
    _submittedPhone = parsed.phoneNumber;
    context.read<RequestPhoneOtpCubit>().fRequestPhoneOtp(
      dialingCode: _submittedDialingCode,
      phone: _submittedPhone,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.signInWithPhone)),
      body: BlocConsumer<RequestPhoneOtpCubit, RequestPhoneOtpState>(
        listener: (BuildContext context, RequestPhoneOtpState state) {
          if (state case ApiCallError(:final message)) {
            showAppSnackBar(
              context: context,
              message: message,
              type: ToastType.error,
            );
          }
          if (state case ApiCallSuccess(:final data)) {
            PhoneOtpRoute(
              dialingCode: _submittedDialingCode,
              phone: _submittedPhone,
              resendAvailableInSeconds: data.resendAvailableInSeconds,
            ).go(context);
          }
        },
        builder: (BuildContext context, RequestPhoneOtpState state) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: <Widget>[
                AppTextFormField.phoneWithCountryCode(
                  controller: _phone,
                  dialingCode: _dialingCode,
                  onDialingCodeChanged: (String code) =>
                      setState(() => _dialingCode = code),
                  labelText: Strings.phoneNumber,
                  validatorType: AuthValidators.fullName,
                ),
                SizedBox(height: 24.h),
                AppElevatedButton(
                  text: Strings.send,
                  isLoading: state.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
