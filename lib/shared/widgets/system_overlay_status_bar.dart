import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemOverlayStatusBar extends StatelessWidget {
  final Widget child;
  final bool dark;

  const SystemOverlayStatusBar({
    required this.child,
    this.dark = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.dark : Brightness.light,
        statusBarBrightness: dark ? Brightness.light : Brightness.dark,
      ),
      child: child,
    );
  }
}
