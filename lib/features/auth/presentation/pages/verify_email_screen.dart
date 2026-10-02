import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/auth_navigation.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/field_errors_scope.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/request_email_otp/request_email_otp_cubit.dart';
import '../controller/verify_email/verify_email_cubit.dart';
import '../widgets/auth_otp_form.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/build_probe.dart';

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

  void _showError(String message) {
    showAppSnackBar(context: context, message: message, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: Strings.emailActivation,
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<RequestEmailOtpCubit, RequestEmailOtpState>(
            listener: (BuildContext context, RequestEmailOtpState state) {
              if (state case ApiCallError(:final message)) {
                _showError(message);
              }
              if (state case ApiCallSuccess(:final data)) {
                context.read<OtpCooldownCubit>().fStart(
                  data.resendAvailableInSeconds,
                );
              }
            },
          ),
        ],
        child: BlocListener<VerifyEmailCubit, VerifyEmailState>(
          listener: (BuildContext context, VerifyEmailState state) {
            if (state case ApiCallError(:final message)) {
              _showError(message);
            }
            if (state.isSuccess) {
              openAuthenticatedDestination(context);
            }
          },
          child:
              BlocSelector<
                VerifyEmailCubit,
                VerifyEmailState,
                Map<String, List<String>>
              >(
                selector: _verifyEmailFieldErrors,
                builder:
                    (
                      BuildContext context,
                      Map<String, List<String>> fieldErrors,
                    ) {
                      return FieldErrorsScope(
                        fieldErrors: fieldErrors,
                        child: AuthOtpForm(
                          header: Text(
                            Strings.otpSentToYourInbox,
                            style: TextStyles.of(
                              size: 16,
                              color: context.colors.textSecondary,
                              height: AuthLayout.bodyLineHeight,
                            ),
                          ),
                          submitButton: (VoidCallback onPressed) {
                            return BlocSelector<
                              VerifyEmailCubit,
                              VerifyEmailState,
                              bool
                            >(
                              selector: (VerifyEmailState state) =>
                                  state.isLoading,
                              builder: (BuildContext context, bool isLoading) {
                                return BuildProbe(
                                  key: BuildProbe.otpSubmit,
                                  child: AppElevatedButton(
                                    text: Strings.verifyCode,
                                    isLoading: isLoading,
                                    enabled: !isLoading,
                                    onPressed: onPressed,
                                  ),
                                );
                              },
                            );
                          },
                          onSubmit: (String code) {
                            context.read<VerifyEmailCubit>().fVerifyEmail(
                              email: widget.email,
                              code: code,
                            );
                          },
                          onResend: () {
                            context
                                .read<RequestEmailOtpCubit>()
                                .fRequestEmailOtp(email: widget.email);
                          },
                        ),
                      );
                    },
              ),
        ),
      ),
    );
  }
}

Map<String, List<String>> _verifyEmailFieldErrors(VerifyEmailState state) {
  return switch (state) {
    ApiCallError(:final fieldErrors) => fieldErrors,
    _ => const <String, List<String>>{},
  };
}
