import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../core/utils/values/text_styles.dart';

class AppOtpField extends StatelessWidget {
  const AppOtpField({
    required this.controller,
    this.length = 6,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final ThemeColors colors = context.colors;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLength: length,
      textAlign: TextAlign.center,
      style: TextStyles.of(size: 24, weight: FontWeight.w600),
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(length),
      ],
      decoration: InputDecoration(
        counterText: '',
        labelText: Strings.verifyCode,
        hintText: List<String>.filled(length, '•').join(),
        filled: true,
        fillColor: colors.foreground,
        contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
      onChanged: onChanged,
      validator: (String? value) {
        if (value == null || value.length != length) {
          return Strings.pleaseEnterValidateOtpCode;
        }
        return null;
      },
    );
  }
}
