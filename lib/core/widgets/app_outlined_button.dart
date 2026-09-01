import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../utils/values/text_styles.dart';

class AppOutlinedButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final TextStyle? textStyle;
  final Size? minimumSize, maximumSize;
  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;

  const AppOutlinedButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.textStyle,
    this.borderRadius,
    this.icon,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: backgroundColor ?? Colors.transparent,
        side: BorderSide(color: borderColor ?? colors.primary),
        padding:
            padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 16.r)),
        minimumSize: minimumSize,
        maximumSize: maximumSize,
        foregroundColor: colors.foreground,
      ),
      child: Center(
        child: Builder(
          builder: (BuildContext context) {
            if (icon != null) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon!,
                  if (text.isNotEmpty)
                    SizedBox(
                      width: 8.w,
                    ),
                  _buttonText,
                ],
              );
            }
            return _buttonText;
          },
        ),
      ),
    );
  }

  Widget get _buttonText => Text(
        text,
        style: textStyle ??
            TextStyles.of(size: 16, weight: FontWeight.w500, color: textColor),
        textAlign: TextAlign.center,
        maxLines: 1,
      );
}
