import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/values/text_styles.dart';
import 'app_shimmer.dart';

class AppElevatedButton extends StatefulWidget {
  final double? width;
  final double? height;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? iconColor;
  final Color? shadowColor;
  final Size? minimumSize;
  final Size? maximumSize;
  final double? borderRadius;
  final double? sidePadding;
  final double? iconSize;
  final double? elevation;
  final String text;
  final TextStyle? textStyle;
  final FutureOr<void> Function()? onPressed;
  final String? icon;
  final String? iconSvg;
  final IconData? iconData;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool isLoading;
  final bool enabled;

  const AppElevatedButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.width,
    this.height,
    this.buttonColor,
    this.borderColor,
    this.iconColor,
    this.shadowColor,
    this.minimumSize,
    this.maximumSize,
    this.borderRadius,
    this.sidePadding,
    this.iconSize,
    this.icon,
    this.iconSvg,
    this.iconData,
    this.textStyle,
    this.textColor,
    this.padding,
    this.margin,
    this.elevation,
    this.isLoading = false,
    this.enabled = true,
  });

  static Widget shimmer({
    BorderRadius? borderRadius,
    EdgeInsetsGeometry? padding,
  }) {
    final resolvedRadius = borderRadius ?? .circular(16.r);
    return ContainerShimmer(
      borderRadius: resolvedRadius,
      child: AppElevatedButton(
        onPressed: null,
        text: 'Button',
        buttonColor: Colors.transparent,
        borderRadius: 16.r,
        padding: padding ?? .symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  @override
  State<AppElevatedButton> createState() => _AppElevatedButtonState();
}

class _AppElevatedButtonState extends State<AppElevatedButton> {
  static const Duration _stateAnimationDuration = Duration(milliseconds: 250);
  static const double _defaultRadius = 16;
  static const double _iconGap = 8;
  static const double _loaderSize = 20;
  static const double _disabledTextOpacity = 0.85;

  bool _isPressInFlight = false;

  bool get _hasIcon =>
      widget.iconSvg != null || widget.icon != null || widget.iconData != null;

  bool get _isVisuallyDisabled =>
      widget.isLoading || !widget.enabled || widget.onPressed == null;

  bool get _blocksPress => _isVisuallyDisabled || _isPressInFlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = widget.borderRadius ?? _defaultRadius.r;
    final backgroundColor = widget.buttonColor ?? colors.primary;

    return AnimatedContainer(
      duration: _stateAnimationDuration,
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? .symmetric(horizontal: widget.sidePadding ?? 0),
      decoration: BoxDecoration(
        borderRadius: .circular(radius),
        boxShadow: _isVisuallyDisabled
            ? const []
            : [
                BoxShadow(
                  color: widget.shadowColor ?? colors.secondary,
                  blurRadius:
                      widget.elevation ?? (context.isDarkTheme ? 16.r : 4.r),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: _blocksPress ? null : _handlePressed,
        clipBehavior: .antiAliasWithSaveLayer,
        style: ElevatedButton.styleFrom(
          padding:
              widget.padding ?? .symmetric(horizontal: 16.w, vertical: 12.h),
          foregroundColor: colors.foreground,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: colors.grey400,
          disabledForegroundColor: colors.white.withValues(
            alpha: _disabledTextOpacity,
          ),
          elevation: 0,
          side: _buttonSide(),
          shape: RoundedRectangleBorder(borderRadius: .circular(radius)),
          minimumSize: widget.minimumSize,
          maximumSize: widget.maximumSize,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: _stateAnimationDuration,
            child: KeyedSubtree(
              key: ValueKey<bool>(widget.isLoading),
              child: widget.isLoading
                  ? _loadingIndicator(colors)
                  : _buttonContent(colors),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePressed() async {
    final onPressed = widget.onPressed;
    if (_blocksPress || onPressed == null) return;

    setState(() => _isPressInFlight = true);
    try {
      await Future<void>.sync(onPressed);
    } finally {
      if (mounted) {
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) setState(() => _isPressInFlight = false);
      }
    }
  }

  BorderSide? _buttonSide() {
    if (_isVisuallyDisabled) {
      return const BorderSide(color: Colors.transparent);
    }
    final borderColor = widget.borderColor;
    if (borderColor == null) return null;
    return BorderSide(color: borderColor);
  }

  Widget _loadingIndicator(ThemeColors colors) {
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _loaderSize.r,
          child: CircularProgressIndicator(
            color: widget.textColor ?? colors.white,
          ).appLoading,
        ),
      ),
    );
  }

  Widget _buttonContent(ThemeColors colors) {
    if (!_hasIcon) return _buttonText(colors);

    return Row(
      mainAxisAlignment: .center,
      mainAxisSize: .min,
      children: [
        _buttonIcon,
        SizedBox(width: _iconGap.w),
        _buttonText(colors),
      ],
    );
  }

  Widget get _buttonIcon {
    final iconColor = widget.iconColor;
    final iconSvg = widget.iconSvg;
    if (iconSvg != null) {
      return SvgPicture.asset(
        iconSvg,
        height: widget.iconSize,
        width: widget.iconSize,
        colorFilter: iconColor != null
            ? ColorFilterExtension.setColor(iconColor)
            : null,
      );
    }

    final icon = widget.icon;
    if (icon != null) {
      return Image.asset(icon, height: widget.iconSize, color: iconColor);
    }

    final iconData = widget.iconData;
    if (iconData != null) {
      return Icon(iconData, size: widget.iconSize, color: iconColor);
    }

    return const SizedBox.shrink();
  }

  Widget _buttonText(ThemeColors colors) {
    final isDisabled = _isVisuallyDisabled;
    return Text(
      widget.text,
      style:
          widget.textStyle ??
          TextStyles.of(
            size: 16,
            weight: .w500,
            color:
                widget.textColor ??
                (isDisabled
                    ? colors.white.withValues(alpha: _disabledTextOpacity)
                    : colors.white),
          ),
      textAlign: .center,
      maxLines: 1,
    );
  }
}
