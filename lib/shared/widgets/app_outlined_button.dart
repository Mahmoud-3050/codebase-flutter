import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../config/themes/extra_colors.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/values/text_styles.dart';
import 'app_shimmer.dart';

class AppOutlinedButton extends StatefulWidget {
  final double? width;
  final double? height;
  final FutureOr<void> Function()? onPressed;
  final String text;
  final TextStyle? textStyle;
  final Size? minimumSize;
  final Size? maximumSize;
  final Color? textColor;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Widget? icon;
  final bool isLoading;
  final bool enabled;

  const AppOutlinedButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.width,
    this.height,
    this.minimumSize,
    this.maximumSize,
    this.padding,
    this.margin,
    this.textStyle,
    this.borderRadius,
    this.icon,
    this.textColor,
    this.borderColor,
    this.backgroundColor,
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
      child: AppOutlinedButton(
        onPressed: null,
        text: 'Button',
        backgroundColor: Colors.transparent,
        borderRadius: 16.r,
        padding: padding ?? .symmetric(horizontal: 16.w, vertical: 12.h),
      ),
    );
  }

  @override
  State<AppOutlinedButton> createState() => _AppOutlinedButtonState();
}

class _AppOutlinedButtonState extends State<AppOutlinedButton> {
  static const Duration _stateAnimationDuration = Duration(milliseconds: 250);
  static const double _defaultRadius = 16;
  static const double _iconGap = 8;
  static const double _loaderSize = 20;

  bool _isPressInFlight = false;

  bool get _isVisuallyDisabled =>
      widget.isLoading || !widget.enabled || widget.onPressed == null;

  bool get _blocksPress => _isVisuallyDisabled || _isPressInFlight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = widget.borderRadius ?? _defaultRadius.r;
    final backgroundColor = widget.backgroundColor ?? Colors.transparent;
    final accentColor =
        widget.textColor ?? widget.borderColor ?? colors.primary;

    return AnimatedContainer(
      duration: _stateAnimationDuration,
      width: widget.width,
      height: widget.height,
      margin: widget.margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(borderRadius: .circular(radius)),
      child: OutlinedButton(
        onPressed: _blocksPress ? null : _handlePressed,
        clipBehavior: .antiAliasWithSaveLayer,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor,
          disabledForegroundColor: colors.grey400,
          side: BorderSide(
            color: _isVisuallyDisabled
                ? colors.grey400
                : widget.borderColor ?? colors.primary,
          ),
          padding:
              widget.padding ?? .symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(borderRadius: .circular(radius)),
          minimumSize: widget.minimumSize,
          maximumSize: widget.maximumSize,
          foregroundColor: colors.foreground,
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: _stateAnimationDuration,
            child: KeyedSubtree(
              key: ValueKey<bool>(widget.isLoading),
              child: widget.isLoading
                  ? _loadingIndicator(accentColor)
                  : _buttonContent(colors, accentColor),
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

  Widget _loadingIndicator(Color accentColor) {
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: _loaderSize.r,
          child: CircularProgressIndicator(color: accentColor).appLoading,
        ),
      ),
    );
  }

  Widget _buttonContent(ThemeColors colors, Color accentColor) {
    final icon = widget.icon;
    if (icon == null) return _buttonText(colors, accentColor);

    return Row(
      mainAxisAlignment: .center,
      mainAxisSize: .min,
      children: [
        icon,
        if (widget.text.isNotEmpty) SizedBox(width: _iconGap.w),
        _buttonText(colors, accentColor),
      ],
    );
  }

  Widget _buttonText(ThemeColors colors, Color accentColor) {
    return Text(
      widget.text,
      style:
          widget.textStyle ??
          TextStyles.of(
            size: 16,
            weight: .w500,
            color: _isVisuallyDisabled ? colors.grey400 : accentColor,
          ),
      textAlign: .center,
      maxLines: 1,
    );
  }
}
