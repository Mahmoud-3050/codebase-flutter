import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../home/presentation/navigation/router.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/request_email_otp/request_email_otp_cubit.dart';
import '../controller/verify_email/verify_email_cubit.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({
    required this.email,
    this.resendAvailableInSeconds = 0,
    super.key,
  });

  final String email;
  final int resendAvailableInSeconds;

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
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
      appBar: AppBar(title: Text(Strings.emailActivation)),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<RequestEmailOtpCubit, RequestEmailOtpState>(
            listener: (BuildContext context, RequestEmailOtpState state) {
              if (state case ApiCallSuccess(:final data)) {
                context.read<OtpCooldownCubit>().fStart(
                  data.resendAvailableInSeconds,
                );
              }
            },
          ),
        ],
        child: BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
          listener: (BuildContext context, VerifyEmailState state) {
            if (state case ApiCallError(
              :final message,
              :final hasFieldErrors,
            )) {
              if (!hasFieldErrors) {
                showAppSnackBar(
                  context: context,
                  message: message,
                  type: ToastType.error,
                );
              }
            }
            if (state.isSuccess) {
              const HomeRoute().go(context);
            }
          },
          builder: (BuildContext context, VerifyEmailState state) {
            return Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                children: <Widget>[
                  Text(Strings.otpSentToYourInbox),
                  SizedBox(height: 16.h),
                  AppOtpField(controller: _code),
                  SizedBox(height: 24.h),
                  AppElevatedButton(
                    text: Strings.verifyCode,
                    isLoading: state.isLoading,
                    enabled: !state.isLoading,
                    onPressed: () => context
                        .read<VerifyEmailCubit>()
                        .fVerifyEmail(email: widget.email, code: _code.text),
                  ),
                  SizedBox(height: 12.h),
                  BlocBuilder<OtpCooldownCubit, OtpCooldownState>(
                    builder: (BuildContext context, OtpCooldownState cooldown) {
                      final bool idle = cooldown is OtpCooldownIdle;
                      return TextButton(
                        onPressed: idle
                            ? () => context
                                  .read<RequestEmailOtpCubit>()
                                  .fRequestEmailOtp(email: widget.email)
                            : null,
                        child: Text(
                          idle
                              ? Strings.resend
                              : '${Strings.resend} (${(cooldown as OtpCooldownCounting).secondsRemaining})',
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
