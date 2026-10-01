import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../shared/widgets/app_otp_field.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import 'auth_tap_target.dart';
import 'build_probe.dart';

/// Shared code-entry form for email verify, phone OTP, and password reset.
///
/// Only the resend control listens to [OtpCooldownCubit], and [submitButton]
/// listens to the submit cubit, so a loading change does not rebuild the
/// code or password fields.
class AuthOtpForm extends StatefulWidget {
  const AuthOtpForm({
    required this.submitButton,
    required this.onSubmit,
    required this.onResend,
    this.header,
    this.extraFields = const <Widget>[],
    super.key,
  });

  final Widget Function(VoidCallback onPressed) submitButton;
  final ValueChanged<String> onSubmit;
  final VoidCallback onResend;
  final Widget? header;
  final List<Widget> extraFields;

  @override
  State<AuthOtpForm> createState() => _AuthOtpFormState();
}

class _AuthOtpFormState extends State<AuthOtpForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            if (widget.header != null) widget.header!,
            BuildProbe(
              key: BuildProbe.otpCode,
              child: AppOtpField(controller: _code),
            ),
            SizedBox(height: 12.h),
            ...widget.extraFields,
            SizedBox(height: 12.h),
            widget.submitButton(() {
              if (!(_formKey.currentState?.validate() ?? false)) {
                return;
              }
              widget.onSubmit(_code.text);
            }),
            SizedBox(height: 12.h),
            _OtpResendButton(onResend: widget.onResend),
          ],
        ),
      ),
    );
  }
}

class _OtpResendButton extends StatelessWidget {
  const _OtpResendButton({required this.onResend});

  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return BlocSelector<OtpCooldownCubit, OtpCooldownState, int>(
      selector: (OtpCooldownState state) {
        return switch (state) {
          OtpCooldownCounting(:final secondsRemaining) => secondsRemaining,
          OtpCooldownIdle() => 0,
        };
      },
      builder: (BuildContext context, int secondsRemaining) {
        final bool idle = secondsRemaining <= 0;
        return TextButton(
          style: authTextButtonStyle(),
          onPressed: idle ? onResend : null,
          child: Text(
            idle ? Strings.resend : '${Strings.resend} ($secondsRemaining)',
          ),
        );
      },
    );
  }
}
