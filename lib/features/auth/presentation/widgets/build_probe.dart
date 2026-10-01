import 'package:flutter/widgets.dart';

/// Counts builds so a test can fail when a loading tick rebuilds a field.
class BuildProbe extends StatefulWidget {
  const BuildProbe({required this.child, super.key});

  static const Key loginEmail = Key('auth-login-email-probe');
  static const Key loginSubmit = Key('auth-login-submit-probe');
  static const Key registerEmail = Key('auth-register-email-probe');
  static const Key registerSubmit = Key('auth-register-submit-probe');
  static const Key otpCode = Key('auth-otp-code-probe');
  static const Key otpSubmit = Key('auth-otp-submit-probe');
  static const Key completeEmail = Key('auth-complete-email-probe');
  static const Key completeSubmit = Key('auth-complete-submit-probe');

  final Widget child;

  @override
  State<BuildProbe> createState() => BuildProbeState();
}

class BuildProbeState extends State<BuildProbe> {
  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds++;
    return widget.child;
  }
}
