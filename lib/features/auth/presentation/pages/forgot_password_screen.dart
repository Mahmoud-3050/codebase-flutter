import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../controller/request_password_reset/request_password_reset_cubit.dart';
import '../navigation/router.dart';
import '../validators/auth_validators.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.forgotPassword)),
      body: BlocListener<RequestPasswordResetCubit, RequestPasswordResetState>(
        listener: (BuildContext context, RequestPasswordResetState state) {
          if (state case ApiCallError(:final message)) {
            showAppSnackBar(
              context: context,
              message: message,
              type: ToastType.error,
            );
          }
          if (state case ApiCallSuccess(:final data)) {
            ResetPasswordRoute(
              $extra: ResetPasswordArgs(
                email: _email.text.trim(),
                resendAvailableInSeconds: data.resendAvailableInSeconds,
              ),
            ).go(context);
          }
        },
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Form(
            key: _formKey,
            child: ListView(
              children: <Widget>[
                AppTextFormField.emailTextField(
                  controller: _email,
                  labelText: Strings.email,
                  validatorType: AuthValidators.email,
                ),
                SizedBox(height: 24.h),
                BlocSelector<
                  RequestPasswordResetCubit,
                  RequestPasswordResetState,
                  bool
                >(
                  selector: (RequestPasswordResetState state) =>
                      state.isLoading,
                  builder: (BuildContext context, bool isLoading) {
                    return AppElevatedButton(
                      text: Strings.send,
                      isLoading: isLoading,
                      enabled: !isLoading,
                      onPressed: () {
                        if (!(_formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        context
                            .read<RequestPasswordResetCubit>()
                            .fRequestPasswordReset(email: _email.text.trim());
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
