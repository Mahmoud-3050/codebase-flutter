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
import '../../../../config/routes/auth_navigation.dart';
import '../../domain/avatar_picker.dart';
import '../../domain/entities/otp_challenge.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/enums/otp_purpose.dart';
import '../../domain/enums/registration_source.dart';
import '../controller/complete_registration/complete_registration_cubit.dart';
import '../controller/request_phone_otp/request_phone_otp_cubit.dart';
import '../controller/verified_phone/verified_phone_cubit.dart';
import '../navigation/router.dart';
import '../validators/auth_validators.dart';
import '../widgets/build_probe.dart';

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
  String? _avatarPath;

  @override
  void initState() {
    super.initState();
    final RegistrationDraft draft = widget.draft;
    _name = TextEditingController(text: draft.suggestedFullName ?? '');
    _email = TextEditingController(text: draft.verifiedEmail ?? '');
    _phone = TextEditingController(text: draft.verifiedPhone ?? '');
    _dialingCode = draft.verifiedDialingCode ?? '+966';
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

  bool _matchesVerifiedPhone(PhoneValidationResult parsed) {
    if (!parsed.isValidPhone) {
      return false;
    }
    final VerifiedPhoneState verified = context
        .read<VerifiedPhoneCubit>()
        .state;
    return verified is PhoneVerified &&
        verified.matches(
          dialingCode: '+${parsed.phoneCode}',
          phone: parsed.phoneNumber,
        );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (widget.draft.source.locksEmail &&
        !_matchesVerifiedPhone(_parsedPhone())) {
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
    final ({String dialingCode, String phone})? phone = _phoneForSubmit();
    if (phone == null && !draft.source.locksPhone) {
      return;
    }
    await context.read<CompleteRegistrationCubit>().fCompleteRegistration(
      registrationToken: draft.registrationToken,
      source: draft.source,
      fullName: _name.text.trim(),
      password: _password.text,
      email: draft.source.locksEmail ? null : _email.text.trim(),
      dialingCode: phone?.dialingCode,
      phone: phone?.phone,
      avatarPath: _avatarPath,
    );
  }

  ({String dialingCode, String phone})? _phoneForSubmit() {
    if (widget.draft.source.locksPhone) {
      return null;
    }
    if (widget.draft.source.locksEmail) {
      final VerifiedPhoneState verified = context
          .read<VerifiedPhoneCubit>()
          .state;
      if (verified is! PhoneVerified) {
        return null;
      }
      return (dialingCode: verified.dialingCode, phone: verified.phone);
    }
    final PhoneValidationResult parsed = _parsedPhone();
    return (dialingCode: '+${parsed.phoneCode}', phone: parsed.phoneNumber);
  }

  Future<void> _onPhoneOtpRequested(OtpChallenge challenge) async {
    final PhoneValidationResult parsed = _parsedPhone();
    if (!parsed.isValidPhone) {
      return;
    }
    final String dialingCode = '+${parsed.phoneCode}';
    final String phone = parsed.phoneNumber;
    final bool? verified = await PhoneOtpRoute(
      $extra: PhoneOtpArgs(
        dialingCode: dialingCode,
        phone: phone,
        resendAvailableInSeconds: challenge.resendAvailableInSeconds,
        purpose: OtpPurpose.verifyPhone,
      ),
    ).push<bool>(context);
    if (verified != true || !mounted) {
      return;
    }
    final PhoneValidationResult current = _parsedPhone();
    if (!current.isValidPhone ||
        '+${current.phoneCode}' != dialingCode ||
        current.phoneNumber != phone) {
      return;
    }
    context.read<VerifiedPhoneCubit>().fMarkVerified(
      dialingCode: dialingCode,
      phone: phone,
    );
    await _complete();
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
                openAuthenticatedDestination(context);
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
            BlocSelector<
              CompleteRegistrationCubit,
              CompleteRegistrationState,
              Map<String, List<String>>
            >(
              selector: (CompleteRegistrationState state) => switch (state) {
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
                      child: _CompleteRegistrationForm(
                        formKey: _formKey,
                        name: _name,
                        email: _email,
                        phone: _phone,
                        password: _password,
                        dialingCode: _dialingCode,
                        avatarPath: _avatarPath,
                        locksEmail: draft.source.locksEmail,
                        locksPhone: draft.source.locksPhone,
                        onDialingCodeChanged: (String code) =>
                            setState(() => _dialingCode = code),
                        onPickAvatar: _pickAvatar,
                        submitButton:
                            BlocSelector<
                              CompleteRegistrationCubit,
                              CompleteRegistrationState,
                              bool
                            >(
                              selector: (CompleteRegistrationState state) =>
                                  state.isLoading,
                              builder:
                                  (BuildContext context, bool isSubmitting) {
                                    return BuildProbe(
                                      key: BuildProbe.completeSubmit,
                                      child: AppElevatedButton(
                                        text: Strings.completeRegistration,
                                        isLoading: isSubmitting,
                                        enabled: !isSubmitting,
                                        onPressed: _submit,
                                      ),
                                    );
                                  },
                            ),
                      ),
                    );
                  },
            ),
      ),
    );
  }
}

class _CompleteRegistrationForm extends StatelessWidget {
  const _CompleteRegistrationForm({
    required this.formKey,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.dialingCode,
    required this.avatarPath,
    required this.locksEmail,
    required this.locksPhone,
    required this.onDialingCodeChanged,
    required this.onPickAvatar,
    required this.submitButton,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController name;
  final TextEditingController email;
  final TextEditingController phone;
  final TextEditingController password;
  final String dialingCode;
  final String? avatarPath;
  final bool locksEmail;
  final bool locksPhone;
  final ValueChanged<String> onDialingCodeChanged;
  final Future<void> Function() onPickAvatar;
  final Widget submitButton;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        padding: EdgeInsets.all(24.w),
        children: <Widget>[
          AppElevatedButton(
            text: avatarPath == null ? Strings.addPhoto : Strings.skipPhoto,
            onPressed: onPickAvatar,
          ),
          SizedBox(height: 16.h),
          AppTextFormField.nameTextField(
            controller: name,
            labelText: Strings.name,
            validatorType: AuthValidators.fullName,
            fieldName: 'full_name',
          ),
          SizedBox(height: 12.h),
          BuildProbe(
            key: BuildProbe.completeEmail,
            child: AppTextFormField.emailTextField(
              controller: email,
              labelText: Strings.email,
              readOnly: locksEmail,
              validatorType: AuthValidators.email,
            ),
          ),
          SizedBox(height: 12.h),
          AppTextFormField.phoneWithCountryCode(
            controller: phone,
            dialingCode: dialingCode,
            onDialingCodeChanged: onDialingCodeChanged,
            labelText: Strings.phoneNumber,
            readOnly: locksPhone,
          ),
          SizedBox(height: 12.h),
          AppTextFormField.passwordTextField(
            controller: password,
            labelText: Strings.password,
            validatorType: AuthValidators.password,
          ),
          SizedBox(height: 24.h),
          submitButton,
        ],
      ),
    );
  }
}
