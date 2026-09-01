import 'package:flutter/material.dart' show ThemeMode;

import '../presentation/theme_colors.dart';
import 'theme_exceptions.dart';

/// Immutable light/dark palettes and the first-launch [ThemeMode].
final class ThemeConfig {
  final ThemeMode defaultMode;
  final ThemeColors light;
  final ThemeColors dark;

  const ThemeConfig({
    required this.light,
    required this.dark,
    this.defaultMode = .light,
  });

  /// Rejects [ThemeMode.system]. Light and dark palettes are required.
  void validate() {
    if (defaultMode == .system) {
      throw const InvalidThemeConfigException(
        'defaultMode cannot be ThemeMode.system. Use ThemeMode.light or ThemeMode.dark.',
      );
    }
  }
}
