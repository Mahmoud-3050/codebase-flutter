import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:themes/themes.dart';

import '../utils/extensions.dart';
import '../utils/values/text_styles.dart';

class AppElevatedButton extends StatelessWidget {
  final Color? buttonColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? shadowColor;
  final Size? minimumSize, maximumSize;
  final double? borderRadius;
  final double? sidePadding;
  final double? verticalPadding;
  final double? horizontalPadding;
  final double? iconSize;
  final double? elevation;
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final String? icon;
  final String? iconSvg;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;

  const AppElevatedButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.buttonColor,
    this.borderColor,
    this.iconColor,
    this.shadowColor,
    this.minimumSize,
    this.maximumSize,
    this.borderRadius,
    this.sidePadding,
    this.verticalPadding,
    this.horizontalPadding,
    this.iconSize,
    this.icon,
    this.iconSvg,
    this.textStyle,
    this.textColor,
    this.padding,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: .symmetric(horizontal: sidePadding ?? 0.0),
      decoration: BoxDecoration(
        borderRadius: .circular(borderRadius ?? 16.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor ?? colors.secondary,
            blurRadius: elevation ?? (context.isDarkTheme ? 16.r : 4.r),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        clipBehavior: .antiAliasWithSaveLayer,
        style: ElevatedButton.styleFrom(
          padding: padding ?? .symmetric(horizontal: 16.w, vertical: 12.h),
          foregroundColor: colors.foreground,
          backgroundColor: buttonColor ?? colors.primary,
          elevation: 0,
          side: borderColor != null
              ? BorderSide(color: borderColor ?? colors.primary)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: .circular(borderRadius ?? 16.r),
          ),
          minimumSize: minimumSize,
          maximumSize: maximumSize,
        ),
        child: Center(
          child: Builder(
            builder: (BuildContext context) {
              if (icon != null || iconSvg != null) {
                return Row(
                  mainAxisAlignment: .center,
                  children: <Widget>[
                    Builder(
                      builder: (context) {
                        if (iconSvg != null) {
                          return SvgPicture.asset(
                            iconSvg!,
                            height: iconSize,
                            width: iconSize,
                            colorFilter: iconColor != null
                                ? ColorFilterExtension.setColor(iconColor!)
                                : null,
                          );
                        } else {
                          return Image.asset(
                            icon!,
                            height: iconSize,
                            color: iconColor,
                          );
                        }
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buttonText(colors),
                  ],
                );
              }
              return _buttonText(colors);
            },
          ),
        ),
      ),
    );
  }

  Widget _buttonText(ThemeColors colors) => Text(
    text,
    style:
        textStyle ??
        TextStyles.of(
          size: 16,
          weight: .w500,
          color: textColor ?? colors.white,
        ),
    textAlign: .center,
    maxLines: 1,
  );
}
