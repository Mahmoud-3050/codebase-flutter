import 'package:flutter/material.dart';
import 'package:themes/themes.dart';

import '../../core/utils/values/fonts.dart';
import '../../core/utils/values/text_styles.dart';

/// Host [ThemeData]: package color layer + fonts / ScreenUtil sizes.
///
/// Call only inside [ScreenUtilInit] so `.w` / `.sp` are valid.
ThemeData appTheme(ThemeColors colors, Brightness brightness) {
  final colorTheme = Themes.buildThemeData(colors, brightness);
  return colorTheme.copyWith(
    textTheme: colorTheme.textTheme.apply(fontFamily: Fonts.current),
    primaryTextTheme:
        colorTheme.primaryTextTheme.apply(fontFamily: Fonts.current),
    dividerTheme: DividerThemeData(
      thickness: 1,
      indent: 4,
      endIndent: 4,
      color: colors.divider,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        alignment: Alignment.center,
        foregroundColor: WidgetStateProperty.all<Color>(colors.primary),
        iconColor: WidgetStateProperty.all<Color>(colors.textPrimary),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: colors.foreground,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: colors.primary,
      unselectedItemColor: colors.hint,
      selectedLabelStyle: TextStyles.of(
        size: 12,
        color: colors.primary,
        fontFamily: Fonts.current,
      ),
      unselectedLabelStyle: TextStyles.of(
        size: 12,
        color: colors.hint,
        fontFamily: Fonts.current,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: colors.textPrimary),
      titleTextStyle: TextStyles.of(
        size: 18,
        weight: FontWeight.w600,
        fontFamily: Fonts.current,
      ),
    ),
  );
}
