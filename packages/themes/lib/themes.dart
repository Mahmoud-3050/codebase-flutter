import 'package:flutter/material.dart';

import 'src/domain/themes.dart';
import 'src/presentation/theme_colors.dart';

export 'src/domain/themes.dart' show Themes;
export 'src/domain/theme_config.dart';
export 'src/domain/theme_change_listener.dart';
export 'src/domain/theme_exceptions.dart';
export 'src/domain/theme_storage.dart';
export 'src/presentation/theme_colors.dart';
export 'src/presentation/widgets/theme_builder.dart';

/// Convenience accessors for the current [Themes] singleton.
extension ThemesContext on BuildContext {
  ThemeColors get colors =>
      Theme.of(this).extension<ThemeColors>() ?? Themes.instance.colors;

  ThemeMode get currentThemeMode => Themes.instance.mode;

  bool get isDarkTheme => Themes.instance.isDark;

  bool get isLightTheme => Themes.instance.isLight;
}
