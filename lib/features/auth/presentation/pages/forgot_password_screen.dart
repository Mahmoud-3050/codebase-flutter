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
      body: BlocConsumer<RequestPasswordResetCubit, RequestPasswordResetState>(
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
              email: _email.text.trim(),
              resendAvailableInSeconds: data.resendAvailableInSeconds,
            ).go(context);
          }
        },
        builder: (BuildContext context, RequestPasswordResetState state) {
          return Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: <Widget>[
                AppTextFormField.emailTextField(
                  controller: _email,
                  labelText: Strings.email,
                  validatorType: AuthValidators.email,
                ),
                SizedBox(height: 24.h),
                AppElevatedButton(
                  text: Strings.send,
                  isLoading: state.isLoading,
                  onPressed: () => context
                      .read<RequestPasswordResetCubit>()
                      .fRequestPasswordReset(email: _email.text.trim()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
