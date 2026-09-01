import 'package:flutter/material.dart';

import '../domain/theme_exceptions.dart';

/// Typed color tokens for one brightness, attached as a [ThemeExtension].
///
/// Host-only colors go in [extra]. Read them through a host extension
/// on [ThemeColors].
@immutable
class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color white;
  final Color black;
  final Color background;
  final Color foreground;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color textPrimary;
  final Color textSecondary;
  final Color unselected;
  final Color divider;
  final Color hint;
  final Color border;
  final Color error;
  final Color success;
  final Map<String, Color> _extra;

  const ThemeColors({
    required this.white,
    required this.black,
    required this.background,
    required this.foreground,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.textPrimary,
    required this.textSecondary,
    required this.unselected,
    required this.divider,
    required this.hint,
    required this.border,
    required this.error,
    required this.success,
    Map<String, Color> extra = const {},
  }) : _extra = extra;

  /// Host extras. Missing keys throw [MissingThemeExtraException].
  Color extra(String key) {
    final color = _extra[key];
    if (color == null) throw MissingThemeExtraException(key);
    return color;
  }

  Map<String, Color> get extras => Map.unmodifiable(_extra);

  @override
  ThemeColors copyWith({
    Color? white,
    Color? black,
    Color? background,
    Color? foreground,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? textPrimary,
    Color? textSecondary,
    Color? unselected,
    Color? divider,
    Color? hint,
    Color? border,
    Color? error,
    Color? success,
    Map<String, Color>? extra,
  }) {
    return ThemeColors(
      white: white ?? this.white,
      black: black ?? this.black,
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      unselected: unselected ?? this.unselected,
      divider: divider ?? this.divider,
      hint: hint ?? this.hint,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
      extra: extra ?? _extra,
    );
  }

  @override
  ThemeColors lerp(ThemeExtension<ThemeColors>? other, double t) {
    if (other is! ThemeColors) return this;
    return ThemeColors(
      white: Color.lerp(white, other.white, t) ?? white,
      black: Color.lerp(black, other.black, t) ?? black,
      background: Color.lerp(background, other.background, t) ?? background,
      foreground: Color.lerp(foreground, other.foreground, t) ?? foreground,
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t) ?? onPrimary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t) ?? onSecondary,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t) ?? textPrimary,
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t) ?? textSecondary,
      unselected: Color.lerp(unselected, other.unselected, t) ?? unselected,
      divider: Color.lerp(divider, other.divider, t) ?? divider,
      hint: Color.lerp(hint, other.hint, t) ?? hint,
      border: Color.lerp(border, other.border, t) ?? border,
      error: Color.lerp(error, other.error, t) ?? error,
      success: Color.lerp(success, other.success, t) ?? success,
      extra: _lerpExtra(_extra, other._extra, t),
    );
  }

  static Map<String, Color> _lerpExtra(
    Map<String, Color> a,
    Map<String, Color> b,
    double t,
  ) {
    final keys = {...a.keys, ...b.keys};
    return {
      for (final key in keys)
        key:
            Color.lerp(a[key] ?? b[key], b[key] ?? a[key], t) ??
            a[key] ??
            b[key]!,
    };
  }
}
