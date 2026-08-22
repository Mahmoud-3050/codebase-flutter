import 'package:flutter/material.dart' show ThemeMode;

/// Host-side hook for theme side effects (status bar, analytics, …).
abstract interface class ThemeChangeListener {
  void onThemeChanged(ThemeMode mode);
}
