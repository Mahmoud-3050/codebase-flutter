import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../config/language/strings.dart';
import '../../../../config/routes/auth_navigation.dart';
import '../../../../core/presentation/api_call_state.dart';
import '../../../../shared/widgets/app_elevated_button.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/field_errors_scope.dart';
import '../../domain/entities/auth_outcome.dart';
import '../../domain/enums/otp_purpose.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/request_phone_otp/request_phone_otp_cubit.dart';
import '../controller/verify_phone_otp/verify_phone_otp_cubit.dart';
import '../navigation/router.dart';
import '../widgets/auth_otp_form.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({
    required this.dialingCode,
    required this.phone,
    this.resendAvailableInSeconds = 0,
    this.purpose = OtpPurpose.phoneSignIn,
    super.key,
  });

  final String dialingCode;
  final String phone;
  final int resendAvailableInSeconds;
  final OtpPurpose purpose;

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
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
    return Scaffold(
      appBar: AppBar(title: Text(Strings.verifyCode)),
      body: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<RequestPhoneOtpCubit, RequestPhoneOtpState>(
            listener: (BuildContext context, RequestPhoneOtpState state) {
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
        child: BlocListener<VerifyPhoneOtpCubit, VerifyPhoneOtpState>(
          listener: (BuildContext context, VerifyPhoneOtpState state) {
            if (state case ApiCallError(:final message)) {
              _showError(message);
            }
            if (state case ApiCallSuccess(:final data)) {
              switch (data) {
                case AuthSessionEstablished():
                  openAuthenticatedDestination(context);
                case AuthRegistrationRequired(:final draft):
                  CompleteRegistrationRoute($extra: draft).go(context);
                case null:
                  Navigator.of(context).pop(true);
              }
            }
          },
          child:
              BlocSelector<
                VerifyPhoneOtpCubit,
                VerifyPhoneOtpState,
                Map<String, List<String>>
              >(
                selector: (VerifyPhoneOtpState state) => switch (state) {
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
                          submitButton: (VoidCallback onPressed) {
                            return BlocSelector<
                              VerifyPhoneOtpCubit,
                              VerifyPhoneOtpState,
                              bool
                            >(
                              selector: (VerifyPhoneOtpState state) =>
                                  state.isLoading,
                              builder: (BuildContext context, bool isLoading) {
                                return AppElevatedButton(
                                  text: Strings.verifyCode,
                                  isLoading: isLoading,
                                  enabled: !isLoading,
                                  onPressed: onPressed,
                                );
                              },
                            );
                          },
                          onSubmit: (String code) {
                            context.read<VerifyPhoneOtpCubit>().fVerifyPhoneOtp(
                              dialingCode: widget.dialingCode,
                              phone: widget.phone,
                              code: code,
                              purpose: widget.purpose,
                            );
                          },
                          onResend: () {
                            context
                                .read<RequestPhoneOtpCubit>()
                                .fRequestPhoneOtp(
                                  dialingCode: widget.dialingCode,
                                  phone: widget.phone,
                                  purpose: widget.purpose,
                                );
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
