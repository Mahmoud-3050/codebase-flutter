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
import '../../../home/presentation/navigation/router.dart';
import '../../domain/avatar_picker.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/enums/otp_purpose.dart';
import '../../domain/enums/registration_source.dart';
import '../controller/complete_registration/complete_registration_cubit.dart';
import '../controller/request_phone_otp/request_phone_otp_cubit.dart';
import '../navigation/router.dart';
import '../validators/auth_validators.dart';

class CompleteRegistrationScreen extends StatefulWidget {
  const CompleteRegistrationScreen({required this.draft, super.key});

  final RegistrationDraft draft;

  @override
  State<CompleteRegistrationScreen> createState() =>
      _CompleteRegistrationScreenState();
}

class _CompleteRegistrationScreenState
    extends State<CompleteRegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  final TextEditingController _password = TextEditingController();
  late String _dialingCode;
  bool _phoneVerified = false;
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final RegistrationDraft draft = widget.draft;
    _name = TextEditingController(text: draft.suggestedFullName ?? '');
    _email = TextEditingController(text: draft.verifiedEmail ?? '');
    _phone = TextEditingController(text: draft.verifiedPhone ?? '');
    _dialingCode = draft.verifiedDialingCode ?? '+966';
    _phoneVerified = draft.source == RegistrationSource.phone;
  }

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

  PhoneValidationResult _parsedPhone() {
    return PhoneValidationService().validatePhoneNumber(
      phoneNumber: _phone.text,
      phoneCode: _dialingCode,
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (widget.draft.source.locksEmail && !_phoneVerified) {
      final PhoneValidationResult parsed = _parsedPhone();
      if (!parsed.isValidPhone) {
        showAppSnackBar(
          context: context,
          message: Strings.errorValidPhoneNumber,
          type: ToastType.error,
        );
        return;
      }
      await context.read<RequestPhoneOtpCubit>().fRequestPhoneOtp(
        dialingCode: '+${parsed.phoneCode}',
        phone: parsed.phoneNumber,
        purpose: OtpPurpose.verifyPhone,
      );
      return;
    }
    await _complete();
  }

  Future<void> _complete() async {
    final RegistrationDraft draft = widget.draft;
    final PhoneValidationResult parsed = _parsedPhone();
    await context.read<CompleteRegistrationCubit>().fCompleteRegistration(
      registrationToken: draft.registrationToken,
      source: draft.source,
      fullName: _name.text.trim(),
      password: _password.text,
      email: draft.source.locksEmail ? null : _email.text.trim(),
      dialingCode: draft.source.locksPhone ? null : '+${parsed.phoneCode}',
      phone: draft.source.locksPhone ? null : parsed.phoneNumber,
      avatarPath: _avatarPath,
    );
  }

  Future<void> _onPhoneOtpRequested(OtpChallenge challenge) async {
    final PhoneValidationResult parsed = _parsedPhone();
    final bool? verified = await PhoneOtpRoute(
      dialingCode: '+${parsed.phoneCode}',
      phone: parsed.phoneNumber,
      resendAvailableInSeconds: challenge.resendAvailableInSeconds,
      purpose: OtpPurpose.verifyPhone.wireName,
    ).push<bool>(context);
    if (verified == true && mounted) {
      _phoneVerified = true;
      await _complete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final RegistrationDraft draft = widget.draft;
    return Scaffold(
      appBar: AppBar(title: Text(Strings.completeRegistration)),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<CompleteRegistrationCubit, CompleteRegistrationState>(
            listener: (BuildContext context, CompleteRegistrationState state) {
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
                if (message == Strings.draftExpired && !hasFieldErrors) {
                  switch (widget.draft.source) {
                    case RegistrationSource.phone:
                      const PhoneSignInRoute().go(context);
                    case RegistrationSource.google:
                    case RegistrationSource.apple:
                      const WelcomeRoute().go(context);
                  }
                }
              }
              if (state.isSuccess) {
                const HomeRoute().go(context);
              }
            },
          ),
          BlocListener<RequestPhoneOtpCubit, RequestPhoneOtpState>(
            listener: (BuildContext context, RequestPhoneOtpState state) {
              if (state case ApiCallError(:final message)) {
                showAppSnackBar(
                  context: context,
                  message: message,
                  type: ToastType.error,
                );
              }
              if (state case ApiCallSuccess(:final data)) {
                _onPhoneOtpRequested(data);
              }
            },
          ),
        ],
        child:
            BlocBuilder<CompleteRegistrationCubit, CompleteRegistrationState>(
              builder: (BuildContext context, CompleteRegistrationState state) {
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
                          readOnly: draft.source.locksEmail,
                          validatorType: AuthValidators.email,
                        ),
                        SizedBox(height: 12.h),
                        AppTextFormField.phoneWithCountryCode(
                          controller: _phone,
                          dialingCode: _dialingCode,
                          onDialingCodeChanged: (String code) =>
                              setState(() => _dialingCode = code),
                          labelText: Strings.phoneNumber,
                          readOnly: draft.source.locksPhone,
                        ),
                        SizedBox(height: 12.h),
                        AppTextFormField.passwordTextField(
                          controller: _password,
                          labelText: Strings.password,
                          validatorType: AuthValidators.password,
                        ),
                        SizedBox(height: 24.h),
                        AppElevatedButton(
                          text: Strings.completeRegistration,
                          isLoading: state.isLoading,
                          onPressed: _submit,
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
