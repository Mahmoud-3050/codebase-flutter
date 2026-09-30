import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../core/services/phone_number/phone_validation_service.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_text_form_field.dart';
import '../../../../shared/widgets/field_errors_scope.dart';
import '../../domain/avatar_picker.dart';
import '../controller/register/register_cubit.dart';
import '../navigation/router.dart';
import '../validators/auth_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String _dialingCode = '+966';
  String? _avatarPath;
  bool _submitted = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    try {
      final String? path = await context.read<AvatarPicker>().pickAvatar();
      if (!mounted) {
        return;
      }
      setState(() => _avatarPath = path ?? _avatarPath);
    } on AvatarRejectedException catch (error) {
      if (!mounted) {
        return;
      }
      showAppSnackBar(
        context: context,
        message: error.reason == AvatarRejectReason.tooLarge
            ? Strings.avatarTooLarge
            : Strings.avatarUnsupportedType,
        type: ToastType.error,
      );
    }
  }

  void _submit() {
    if (_submitted) {
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final PhoneValidationResult parsed = PhoneValidationService()
        .validatePhoneNumber(phoneNumber: _phone.text, phoneCode: _dialingCode);
    setState(() => _submitted = true);
    context.read<RegisterCubit>().fRegister(
      fullName: _name.text.trim(),
      email: _email.text.trim(),
      dialingCode: '+${parsed.phoneCode}',
      phone: parsed.phoneNumber,
      password: _password.text,
      avatarPath: _avatarPath,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(Strings.createAccount)),
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (BuildContext context, RegisterState state) {
          if (state case ApiCallError(:final message, :final hasFieldErrors)) {
            setState(() => _submitted = false);
            if (!hasFieldErrors) {
              showAppSnackBar(
                context: context,
                message: message,
                type: ToastType.error,
              );
            }
            if (message == Strings.emailTaken) {
              const LoginRoute().go(context);
            }
          }
          if (state case ApiCallSuccess(:final data)) {
            VerifyEmailRoute(
              email: _email.text.trim(),
              resendAvailableInSeconds: data.resendAvailableInSeconds,
            ).go(context);
          }
        },
        builder: (BuildContext context, RegisterState state) {
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
                  AppElevatedButton(
                    text: _avatarPath == null
                        ? Strings.addPhoto
                        : Strings.skipPhoto,
                    onPressed: _pickAvatar,
                  ),
                  SizedBox(height: 16.h),
                  AppTextFormField.nameTextField(
                    controller: _name,
                    labelText: Strings.name,
                    validatorType: AuthValidators.fullName,
                    fieldName: 'full_name',
                  ),
                  SizedBox(height: 12.h),
                  AppTextFormField.emailTextField(
                    controller: _email,
                    labelText: Strings.email,
                    validatorType: AuthValidators.email,
                  ),
                  SizedBox(height: 12.h),
                  AppTextFormField.phoneWithCountryCode(
                    controller: _phone,
                    dialingCode: _dialingCode,
                    onDialingCodeChanged: (String code) =>
                        setState(() => _dialingCode = code),
                    labelText: Strings.phoneNumber,
                  ),
                  SizedBox(height: 12.h),
                  AppTextFormField.passwordTextField(
                    controller: _password,
                    labelText: Strings.password,
                    validatorType: AuthValidators.password,
                  ),
                  SizedBox(height: 24.h),
                  AppElevatedButton(
                    text: Strings.createAccount,
                    isLoading: state.isLoading,
                    enabled: !state.isLoading,
                    onPressed: _submit,
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
