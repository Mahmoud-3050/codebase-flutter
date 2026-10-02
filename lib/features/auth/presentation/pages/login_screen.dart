import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/utils/values/text_styles.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/field_errors_scope.dart';
import '../../../../config/routes/auth_navigation.dart';
import '../../domain/entities/login_outcome.dart';
import '../controller/login/login_cubit.dart';
import '../navigation/router.dart';
import '../auth_field_errors.dart';
import '../validators/auth_validators.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_tap_target.dart';
import '../widgets/build_probe.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: Strings.signIn,
      body: BlocListener<LoginCubit, LoginState>(
        listener: (BuildContext context, LoginState state) {
          if (state case ApiCallError(:final message, :final hasFieldErrors)) {
            if (!hasFieldErrors) {
              final bool offline = message == Strings.noInternetConnection;
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
                actionLabel: offline ? Strings.refresh : null,
                onAction: offline
                    ? () => context.read<LoginCubit>().fLogin(
                        email: _email.text.trim(),
                        password: _password.text,
                      )
                    : null,
              );
            }
          }
          if (state case ApiCallSuccess<LoginOutcome>(:final data)) {
            switch (data) {
              case LoginSucceeded():
                openAuthenticatedDestination(context);
              case LoginNeedsEmailVerification(:final challenge):
                VerifyEmailRoute(
                  $extra: VerifyEmailArgs(
                    email: _email.text.trim(),
                    resendAvailableInSeconds:
                        challenge.resendAvailableInSeconds,
                  ),
                ).go(context);
            }
          }
        },
        child: BlocSelector<LoginCubit, LoginState, Map<String, List<String>>>(
          selector: _loginFieldErrors,
          builder:
              (BuildContext context, Map<String, List<String>> fieldErrors) {
                return FieldErrorsScope(
                  fieldErrors: fieldErrors,
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: EdgeInsets.all(24.w),
                      children: <Widget>[
                        BuildProbe(
                          key: BuildProbe.loginEmail,
                          child: AppTextFormField.emailTextField(
                            controller: _email,
                            labelText: Strings.email,
                            validatorType: AuthValidators.email,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        AppTextFormField.passwordTextField(
                          controller: _password,
                          labelText: Strings.password,
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: TextButton(
                            style: authTextButtonStyle(),
                            onPressed: () =>
                                const ForgotPasswordRoute().go(context),
                            child: Text(
                              Strings.forgotPassword,
                              style: TextStyles.of(
                                size: 14,
                                color: context.colors.primary,
                                height: AuthLayout.bodyLineHeight,
                              ),
                            ),
                          ),
                        ),
                        BlocSelector<LoginCubit, LoginState, bool>(
                          selector: (LoginState state) => state.isLoading,
                          builder: (BuildContext context, bool isLoading) {
                            return BuildProbe(
                              key: BuildProbe.loginSubmit,
                              child: AppElevatedButton(
                                text: Strings.signIn,
                                isLoading: isLoading,
                                enabled: !isLoading,
                                onPressed: () {
                                  if (!(_formKey.currentState?.validate() ??
                                      false)) {
                                    return;
                                  }
                                  context.read<LoginCubit>().fLogin(
                                    email: _email.text.trim(),
                                    password: _password.text,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
        ),
      ),
    );
  }
}

Map<String, List<String>> _loginFieldErrors(LoginState state) {
  return authFieldErrors(state);
}
