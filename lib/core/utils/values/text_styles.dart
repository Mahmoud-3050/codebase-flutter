import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

/// Figma size (px) + [FontWeight] → [TextStyle].
///
/// `size` is passed through `.sp`. Color defaults to
/// [Themes.instance.colors.textPrimary] and overflow to [TextOverflow.ellipsis].
/// Remaining fields match [TextStyle].
abstract final class TextStyles {
  static TextStyle of({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    Color? backgroundColor,
    FontStyle? fontStyle,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    TextLeadingDistribution? leadingDistribution,
    Locale? locale,
    List<Shadow>? shadows,
    List<FontFeature>? fontFeatures,
    List<FontVariation>? fontVariations,
    TextDecoration? decoration,
    Color? decorationColor,
    TextDecorationStyle? decorationStyle,
    double? decorationThickness,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    TextOverflow overflow = TextOverflow.ellipsis,
    bool inherit = true,
    Paint? foreground,
    Paint? background,
    TextBaseline? textBaseline,
    String? debugLabel,
    String? package,
  }) {
    return TextStyle(
      inherit: inherit,
      color: color ?? Themes.instance.colors.textPrimary,
      backgroundColor: backgroundColor,
      fontSize: size.sp,
      fontWeight: weight,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
      wordSpacing: wordSpacing,
      height: height,
      leadingDistribution: leadingDistribution,
      locale: locale,
      foreground: foreground,
      background: background,
      shadows: shadows,
      fontFeatures: fontFeatures,
      fontVariations: fontVariations,
      decoration: decoration,
      decorationColor: decorationColor,
      decorationStyle: decorationStyle,
      decorationThickness: decorationThickness,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      overflow: overflow,
      textBaseline: textBaseline,
      debugLabel: debugLabel,
      package: package,
    );
  }
}
