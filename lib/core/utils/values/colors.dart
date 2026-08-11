import 'package:flutter/material.dart';

class MyColors {
  //region: shared
  static final Color baseColorShimmer = Colors.grey.shade300;
  static final Color highlightColorShimmer = Colors.grey.shade100;
  static const Color grey100 = Color(0xFFf1f1f1);
  static const Color grey200 = Color(0xFFcfcfd1);
  static const Color grey300 = Color(0xFFa7a7ad);
  static const Color grey400 = Color(0xFF828289);
  static const Color grey500 = Color(0xFF5e5e67);
  static const Color grey600 = Color(0xFF3d3d44);
  static const Color grey700 = Color(0xFF1e1e23);
  static const Color yellow = Color(0xFFECC826);
  static const Color orange = Color(0xFFFFA800);
  static const Color green = Color(0xFF00B507);
  static const Color red = Color(0xFFED3241);
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      secondary,
      primary,
    ],
    begin: AlignmentDirectional.topCenter,
    end: AlignmentDirectional.bottomCenter,
    stops: [0.0, 1.0],
  );
  //endregion

  //region: light mode
  static const Color white = Colors.white;
  static const Color background = Color(0xFFF4F4F4);
  static const Color foreground = Color(0xFFFFFFFF);
  static const Color primary = Color(0xff5F17ED);
  static const Color secondary = Color(0xff5F14B7);
  static const Color textPrimary = Color(0xFF161616);
  static const Color textSecondary = Color(0xFF525252);
  static const Color unselected = Color(0xFF878EAF);
  static const Color divider = Color(0x26738277);
  static const Color hint = Color(0xFF6E6E75);
  static const Color error = Color(0xFFED5526);
  static const Color border = Color(0xFFC5C6CC);
  static const Color greyBackground = Color(0xFFEAEBED);
  static const Color greyForeground = Color(0xFFD8D9DF);
  static const Color progressBarBackground = Color(0xFFDADCE2);
  //endregion

  //region: dark mode
  static const Color black = Colors.black;
  static const Color backgroundDark = Color(0xFF17151A);
  static const Color upBackgroundDark = Color(0xFF1B222A);
  static const Color primaryDark = Color(0xff5F17ED);
  static const Color secondaryDark = Color(0xff5F14B7);
  static const Color textPrimaryDark = Color(0xFFECEBEB);
  static const Color textSecondaryDark = Color(0xFF9D9D9C);
  static const Color unselectedDark = Color(0xFF9DA8A5);
  static const Color dividerDark = Color(0x26DDE8E0);
  static const Color hintDark = Color(0xFF8F9098);
  static const Color errorDark = Color(0xFFFF5F5F);
  static const Color borderDark = Color(0xFFC5C6CC);
  static const Color greyBackgroundDark = Color(0xFF13151C);
  static const Color greyForegroundDark = Color(0xFF1C1F26);
  static const Color progressBarBackgroundDark = Color(0xFF282C36);
  //endregion

}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color white;
  final Color black;
  final Color background;
  final Color foreground;
  final Color primary;
  final Color secondary;
  final Color grey100;
  final Color grey200;
  final Color grey300;
  final Color grey400;
  final Color grey500;
  final Color grey600;
  final Color grey700;
  final Color textPrimary;
  final Color textSecondary;
  final Color yellow;
  final Color orange;
  final Color green;
  final Color red;
  final Color unselected;
  final Color divider;
  final Color hint;
  final Color error;
  final Color border;
  final Color greyBackground;
  final Color greyForeground;
  final Color progressBarBackground;

  const AppColors({
    required this.white,
    required this.black,
    required this.background,
    required this.foreground,
    required this.primary,
    required this.secondary,
    required this.grey100,
    required this.grey200,
    required this.grey300,
    required this.grey400,
    required this.grey500,
    required this.grey600,
    required this.grey700,
    required this.textPrimary,
    required this.textSecondary,
    required this.yellow,
    required this.orange,
    required this.green,
    required this.red,
    required this.unselected,
    required this.divider,
    required this.hint,
    required this.error,
    required this.border,
    required this.greyBackground,
    required this.greyForeground,
    required this.progressBarBackground,
  });

  @override
  AppColors copyWith({
    Color? white,
    Color? black,
    Color? background,
    Color? foreground,
    Color? primary,
    Color? secondary,
    Color? grey100,
    Color? grey200,
    Color? grey300,
    Color? grey400,
    Color? grey500,
    Color? grey600,
    Color? grey700,
    Color? textPrimary,
    Color? textSecondary,
    Color? yellow,
    Color? orange,
    Color? green,
    Color? red,
    Color? unselected,
    Color? divider,
    Color? hint,
    Color? error,
    Color? border,
    Color? greyBackground,
    Color? greyForeground,
    Color? progressBarBackground,
  }) {
    return AppColors(
      white: white ?? this.white,
      black: black ?? this.black,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      grey100: grey100 ?? this.grey100,
      grey200: grey200 ?? this.grey200,
      grey300: grey300 ?? this.grey300,
      grey400: grey400 ?? this.grey400,
      grey500: grey500 ?? this.grey500,
      grey600: grey600 ?? this.grey600,
      grey700: grey700 ?? this.grey700,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      yellow: yellow ?? this.yellow,
      orange: orange ?? this.orange,
      green: green ?? this.green,
      red: red ?? this.red,
      unselected: unselected ?? this.unselected,
      divider: divider ?? this.divider,
      hint: hint ?? this.hint,
      error: error ?? this.error,
      border: border ?? this.border,
      greyBackground: greyBackground ?? this.greyBackground,
      greyForeground: greyForeground ?? this.greyForeground,
      progressBarBackground: progressBarBackground ?? this.progressBarBackground,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors> other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      white: Color.lerp(white, other.white, t) ?? white,
      black: Color.lerp(black, other.black, t) ?? black,
      background: Color.lerp(background, other.background, t) ?? background,
      foreground: Color.lerp(foreground, other.foreground, t) ?? foreground,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      grey100: Color.lerp(grey100, other.grey100, t) ?? grey100,
      grey200: Color.lerp(grey200, other.grey200, t) ?? grey200,
      grey300: Color.lerp(grey300, other.grey300, t) ?? grey300,
      grey400: Color.lerp(grey400, other.grey400, t) ?? grey400,
      grey500: Color.lerp(grey500, other.grey500, t) ?? grey500,
      grey600: Color.lerp(grey600, other.grey600, t) ?? grey600,
      grey700: Color.lerp(grey700, other.grey700, t) ?? grey700,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      yellow: Color.lerp(yellow, other.yellow, t) ?? yellow,
      orange: Color.lerp(orange, other.orange, t) ?? orange,
      green: Color.lerp(green, other.green, t) ?? green,
      red: Color.lerp(red, other.red, t) ?? red,
      unselected: Color.lerp(unselected, other.unselected, t) ?? unselected,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      hint: Color.lerp(hint, other.hint, t) ?? hint,
      error: Color.lerp(error, other.error, t) ?? error,
      border: Color.lerp(border, other.border, t) ?? border,
      greyBackground: Color.lerp(greyBackground, other.greyBackground, t) ?? greyBackground,
      greyForeground: Color.lerp(greyForeground, other.greyForeground, t) ?? greyForeground,
      progressBarBackground: Color.lerp(progressBarBackground, other.progressBarBackground, t) ?? progressBarBackground,
    );
  }
}
