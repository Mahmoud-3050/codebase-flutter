import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../home/presentation/navigation/router.dart';
import '../../domain/entities/auth_outcome.dart';
import '../../domain/enums/otp_purpose.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/request_phone_otp/request_phone_otp_cubit.dart';
import '../controller/verify_phone_otp/verify_phone_otp_cubit.dart';
import '../navigation/router.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({
    required this.dialingCode,
    required this.phone,
    this.resendAvailableInSeconds = 0,
    this.purpose = OtpPurpose.phoneSignIn,
    super.key,
  });

  final String dialingCode;
  final String phone;
  final int resendAvailableInSeconds;
  final OtpPurpose purpose;

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final TextEditingController _code = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<OtpCooldownCubit>().fStart(widget.resendAvailableInSeconds);
    });
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.verifyCode)),
      body: BlocConsumer<VerifyPhoneOtpCubit, VerifyPhoneOtpState>(
        listener: (BuildContext context, VerifyPhoneOtpState state) {
          if (state case ApiCallError(:final message)) {
            showAppSnackBar(
              context: context,
              message: message,
              type: ToastType.error,
            );
          }
          if (state case ApiCallSuccess(:final data)) {
            switch (data) {
              case AuthSessionEstablished():
                const HomeRoute().go(context);
              case AuthRegistrationRequired(:final draft):
                CompleteRegistrationRoute($extra: draft).go(context);
              case null:
                Navigator.of(context).pop(true);
            }
          }
        },
        builder: (BuildContext context, VerifyPhoneOtpState state) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: <Widget>[
                AppOtpField(controller: _code),
                SizedBox(height: 24.h),
                AppElevatedButton(
                  text: Strings.verifyCode,
                  isLoading: state.isLoading,
                  onPressed: () =>
                      context.read<VerifyPhoneOtpCubit>().fVerifyPhoneOtp(
                        dialingCode: widget.dialingCode,
                        phone: widget.phone,
                        code: _code.text,
                        purpose: widget.purpose,
                      ),
                ),
                BlocBuilder<OtpCooldownCubit, OtpCooldownState>(
                  builder: (BuildContext context, OtpCooldownState cooldown) {
                    final bool idle = cooldown is OtpCooldownIdle;
                    return TextButton(
                      onPressed: idle
                          ? () => context
                                .read<RequestPhoneOtpCubit>()
                                .fRequestPhoneOtp(
                                  dialingCode: widget.dialingCode,
                                  phone: widget.phone,
                                )
                          : null,
                      child: Text(Strings.resend),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
