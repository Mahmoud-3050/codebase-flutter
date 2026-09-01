import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import 'color_keys.dart';

/// Light/dark palettes. Edit hex here — hot reload.
abstract final class ColorsPalettes {
  static const Map<String, Color> _sharedExtra = {
    ColorKeys.grey100: Color(0xFFF1F1F1),
    ColorKeys.grey200: Color(0xFFCFCFD1),
    ColorKeys.grey300: Color(0xFFA7A7AD),
    ColorKeys.grey400: Color(0xFF828289),
    ColorKeys.grey500: Color(0xFF5E5E67),
    ColorKeys.grey600: Color(0xFF3D3D44),
    ColorKeys.grey700: Color(0xFF1E1E23),
    ColorKeys.yellow: Color(0xFFECC826),
    ColorKeys.orange: Color(0xFFFFA800),
    ColorKeys.green: Color(0xFF00B507),
    ColorKeys.red: Color(0xFFED3241),
    ColorKeys.baseColorShimmer: Color(0xFFE0E0E0),
    ColorKeys.highlightColorShimmer: Color(0xFFF5F5F5),
  };

  static const ThemeColors _light = ThemeColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    background: Color(0xFFF4F4F4),
    foreground: Color(0xFFFFFFFF),
    primary: Color(0xFF5F17ED),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF5F14B7),
    onSecondary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF161616),
    textSecondary: Color(0xFF525252),
    unselected: Color(0xFF878EAF),
    divider: Color(0x26738277),
    hint: Color(0xFF6E6E75),
    border: Color(0xFFC5C6CC),
    error: Color(0xFFED5526),
    success: Color(0xFF00B507),
    extra: {
      ..._sharedExtra,
      ColorKeys.greyBackground: Color(0xFFEAEBED),
      ColorKeys.greyForeground: Color(0xFFD8D9DF),
      ColorKeys.progressBarBackground: Color(0xFFDADCE2),
    },
  );

  static const ThemeColors _dark = ThemeColors(
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    background: Color(0xFF17151A),
    foreground: Color(0xFF1B222A),
    primary: Color(0xFF5F17ED),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF5F14B7),
    onSecondary: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFECEBEB),
    textSecondary: Color(0xFF9D9D9C),
    unselected: Color(0xFF9DA8A5),
    divider: Color(0x26DDE8E0),
    hint: Color(0xFF8F9098),
    border: Color(0xFFC5C6CC),
    error: Color(0xFFFF5F5F),
    success: Color(0xFF00B507),
    extra: {
      ..._sharedExtra,
      ColorKeys.greyBackground: Color(0xFF13151C),
      ColorKeys.greyForeground: Color(0xFF1C1F26),
      ColorKeys.progressBarBackground: Color(0xFF282C36),
    },
  );

  static const ThemeConfig config = ThemeConfig(light: _light, dark: _dark);
}
