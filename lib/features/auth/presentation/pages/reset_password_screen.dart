import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/field_errors_scope.dart';
import '../../../../config/routes/auth_navigation.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/request_password_reset/request_password_reset_cubit.dart';
import '../controller/reset_password/reset_password_cubit.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_otp_form.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    required this.email,
    this.resendAvailableInSeconds = 0,
    super.key,
  });

  final String email;
  final int resendAvailableInSeconds;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmation = TextEditingController();

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
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  void _showError(String message) {
    showAppSnackBar(context: context, message: message, type: ToastType.error);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.resetPassword)),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<RequestPasswordResetCubit, RequestPasswordResetState>(
            listener: (BuildContext context, RequestPasswordResetState state) {
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
        child: BlocListener<ResetPasswordCubit, ResetPasswordState>(
          listener: (BuildContext context, ResetPasswordState state) {
            if (state case ApiCallError(:final message)) {
              _showError(message);
            }
            if (state.isSuccess) {
              openAuthenticatedDestination(context);
            }
          },
          child:
              BlocSelector<
                ResetPasswordCubit,
                ResetPasswordState,
                Map<String, List<String>>
              >(
                selector: (ResetPasswordState state) => switch (state) {
                  ApiCallError(:final fieldErrors) => fieldErrors,
                  _ => const <String, List<String>>{},
                },
                builder:
                    (
                      BuildContext context,
                      Map<String, List<String>> fieldErrors,
                    ) {
                      return FieldErrorsScope(
                        fieldErrors: fieldErrors,
                        child: AuthOtpForm(
                          extraFields: <Widget>[
                            AppTextFormField.passwordTextField(
                              controller: _password,
                              labelText: Strings.newPassword,
                              validatorType: AuthValidators.password,
                            ),
                            SizedBox(height: 12.h),
                            AppTextFormField.passwordTextField(
                              controller: _confirmation,
                              labelText: Strings.confirmPassword,
                              confirmPasswordController: _password,
                              fieldName: 'password_confirmation',
                            ),
                          ],
                          submitButton: (VoidCallback onPressed) {
                            return BlocSelector<
                              ResetPasswordCubit,
                              ResetPasswordState,
                              bool
                            >(
                              selector: (ResetPasswordState state) =>
                                  state.isLoading,
                              builder: (BuildContext context, bool isLoading) {
                                return AppElevatedButton(
                                  text: Strings.confirm,
                                  isLoading: isLoading,
                                  enabled: !isLoading,
                                  onPressed: onPressed,
                                );
                              },
                            );
                          },
                          onSubmit: (String code) {
                            context.read<ResetPasswordCubit>().fResetPassword(
                              email: widget.email,
                              code: code,
                              password: _password.text,
                              passwordConfirmation: _confirmation.text,
                            );
                          },
                          onResend: () {
                            context
                                .read<RequestPasswordResetCubit>()
                                .fRequestPasswordReset(email: widget.email);
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
