import 'package:flutter/material.dart';

import 'theme_colors.dart';

/// Color-complete [ThemeData]. Hosts `copyWith` fonts and ScreenUtil sizes.
abstract final class ThemeDataFactory {
  static ThemeData build(ThemeColors colors, Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      extensions: <ThemeExtension<ThemeColors>>[colors],
      primaryColor: colors.primary,
      primaryColorLight: colors.primary,
      primaryColorDark: colors.primary,
      scaffoldBackgroundColor: colors.background,
      unselectedWidgetColor: colors.unselected,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: colors.primary,
        onPrimary: colors.onPrimary,
        secondary: colors.secondary,
        onSecondary: colors.onSecondary,
        error: colors.error,
        onError: colors.onPrimary,
        surface: colors.foreground,
        onSurface: colors.textPrimary,
      ),
      iconTheme: IconThemeData(color: colors.textPrimary),
      dividerTheme: DividerThemeData(color: colors.divider),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.background,
        barrierColor: colors.black.withValues(alpha: 0.75),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        collapsedIconColor: colors.textPrimary,
        textColor: colors.secondary,
        collapsedTextColor: colors.secondary,
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor: WidgetStateProperty.all<Color>(colors.onPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
          alignment: Alignment.center,
          foregroundColor: WidgetStateProperty.all<Color>(colors.primary),
          iconColor: WidgetStateProperty.all<Color>(colors.textPrimary),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: colors.textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.foreground,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.unselected,
      ),
    );
  }
}
