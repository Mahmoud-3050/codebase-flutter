import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../core/utils/values/fonts.dart';

/// Host [ThemeData]: package color layer + fonts / ScreenUtil sizes.
///
/// Call only inside [ScreenUtilInit] so `.w` / `.sp` are valid.
ThemeData appTheme(ThemeColors colors, Brightness brightness) {
  final colorTheme = Themes.buildThemeData(colors, brightness);
  return colorTheme.copyWith(
    textTheme: colorTheme.textTheme.apply(fontFamily: Fonts.poppins),
    primaryTextTheme:
        colorTheme.primaryTextTheme.apply(fontFamily: Fonts.poppins),
    dividerTheme: DividerThemeData(
      thickness: 1.w,
      indent: 4.w,
      endIndent: 4.w,
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
      selectedLabelStyle: TextStyle(
        fontFamily: Fonts.poppins,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: colors.primary,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Fonts.poppins,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: colors.hint,
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
        fontFamily: Fonts.poppins,
        color: colors.textPrimary,
        fontSize: 18.sp,
      ),
    ),
  );
}
