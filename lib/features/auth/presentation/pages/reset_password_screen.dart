import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../home/presentation/navigation/router.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/reset_password/reset_password_cubit.dart';
import '../validators/auth_validators.dart';

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
  final TextEditingController _code = TextEditingController();
  final TextEditingController _password = TextEditingController();

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
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.resetPassword)),
      body: BlocConsumer<ResetPasswordCubit, ResetPasswordState>(
        listener: (BuildContext context, ResetPasswordState state) {
          if (state case ApiCallError(:final message)) {
            showAppSnackBar(
              context: context,
              message: message,
              type: ToastType.error,
            );
          }
          if (state.isSuccess) {
            const HomeRoute().go(context);
          }
        },
        builder: (BuildContext context, ResetPasswordState state) {
          return ListView(
            padding: EdgeInsets.all(24.w),
            children: <Widget>[
              AppOtpField(controller: _code),
              SizedBox(height: 12.h),
              AppTextFormField.passwordTextField(
                controller: _password,
                labelText: Strings.newPassword,
                validatorType: AuthValidators.password,
              ),
              SizedBox(height: 24.h),
              AppElevatedButton(
                text: Strings.confirm,
                isLoading: state.isLoading,
                onPressed: () =>
                    context.read<ResetPasswordCubit>().fResetPassword(
                      email: widget.email,
                      code: _code.text,
                      password: _password.text,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}
