import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/field_errors_scope.dart';
import '../../../home/presentation/navigation/router.dart';
import '../../domain/entities/login_outcome.dart';
import '../controller/login/login_cubit.dart';
import '../navigation/router.dart';
import '../validators/auth_validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.signIn)),
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (BuildContext context, LoginState state) {
          if (state case ApiCallError(:final message, :final hasFieldErrors)) {
            setState(() => _submitted = false);
            if (!hasFieldErrors) {
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
              );
            }
          }
          if (state case ApiCallSuccess<LoginOutcome>(:final data)) {
            switch (data) {
              case LoginSucceeded():
                const HomeRoute().go(context);
              case LoginNeedsEmailVerification(:final challenge):
                VerifyEmailRoute(
                  email: _email.text.trim(),
                  resendAvailableInSeconds: challenge.resendAvailableInSeconds,
                ).go(context);
            }
          }
        },
        builder: (BuildContext context, LoginState state) {
          return FieldErrorsScope(
            fieldErrors: switch (state) {
              ApiCallError(:final fieldErrors) => fieldErrors,
              _ => const <String, List<String>>{},
            },
            child: Form(
              key: _formKey,
              child: ListView(
                padding: EdgeInsets.all(24.w),
                children: <Widget>[
                  AppTextFormField.emailTextField(
                    controller: _email,
                    labelText: Strings.email,
                    validatorType: AuthValidators.email,
                  ),
                  SizedBox(height: 12.h),
                  AppTextFormField.passwordTextField(
                    controller: _password,
                    labelText: Strings.password,
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(
                      onPressed: () => const ForgotPasswordRoute().go(context),
                      child: Text(Strings.forgotPassword),
                    ),
                  ),
                  AppElevatedButton(
                    text: Strings.signIn,
                    isLoading: state.isLoading,
                    enabled: !state.isLoading && !_submitted,
                    onPressed: () {
                      if (!(_formKey.currentState?.validate() ?? false)) {
                        return;
                      }
                      setState(() => _submitted = true);
                      context.read<LoginCubit>().fLogin(
                        email: _email.text.trim(),
                        password: _password.text,
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
