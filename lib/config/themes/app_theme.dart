import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/values/colors.dart';
import '../../core/utils/values/fonts.dart';


ThemeData getAppTheme({
  required BuildContext context,
  required bool isLightTheme,
}) {
  return ThemeData(
    extensions: <ThemeExtension<AppColors>>[
      AppColors(
        white: MyColors.white,
        black: MyColors.black,
        grey100: MyColors.grey100,
        grey200: MyColors.grey200,
        grey300: MyColors.grey300,
        grey500: MyColors.grey500,
        grey400: MyColors.grey400,
        grey600: MyColors.grey600,
        grey700: MyColors.grey700,
        yellow: MyColors.yellow,
        orange: MyColors.orange,
        green: MyColors.green,
        red: MyColors.red,
        background: isLightTheme ? MyColors.background : MyColors.backgroundDark,
        foreground: isLightTheme ? MyColors.foreground : MyColors.upBackgroundDark,
        primary: isLightTheme ? MyColors.primary : MyColors.primaryDark,
        secondary: isLightTheme ? MyColors.secondary : MyColors.secondaryDark,
        textPrimary: isLightTheme ? MyColors.textPrimary : MyColors.textPrimaryDark,
        textSecondary: isLightTheme ? MyColors.textSecondary : MyColors.textSecondaryDark,
        unselected: isLightTheme ? MyColors.unselected : MyColors.unselectedDark,
        divider: isLightTheme ? MyColors.divider : MyColors.dividerDark,
        hint: isLightTheme ? MyColors.hint : MyColors.hintDark,
        error: isLightTheme ? MyColors.error : MyColors.errorDark,
        border: isLightTheme ? MyColors.border : MyColors.borderDark,
        greyBackground: isLightTheme ? MyColors.greyBackground : MyColors.greyBackgroundDark,
        greyForeground: isLightTheme ? MyColors.greyForeground : MyColors.greyForegroundDark,
        progressBarBackground: isLightTheme ? MyColors.progressBarBackground : MyColors.progressBarBackgroundDark,
      ),
    ],
    iconTheme: IconThemeData(
      color: isLightTheme ? MyColors.textPrimary : MyColors.textPrimaryDark,
    ),
    unselectedWidgetColor: isLightTheme ? MyColors.unselected : MyColors.unselectedDark,
    primaryColor: isLightTheme ? MyColors.primary : MyColors.primaryDark,
    colorScheme: isLightTheme
        ? const ColorScheme.light(
      primary: MyColors.primary,
      secondary: MyColors.yellow,
      onSecondary: MyColors.white,
      error: MyColors.error,
    )
        : const ColorScheme.dark(
      primary: MyColors.primaryDark,
      secondary: MyColors.yellow,
      onSecondary: MyColors.white,
      error: MyColors.errorDark,
    ),
    dividerTheme: DividerThemeData(
      thickness: 1.w,
      indent: 4.w,
      endIndent: 4.w,
      color: isLightTheme ? MyColors.divider : MyColors.dividerDark,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: isLightTheme ? MyColors.background : MyColors.backgroundDark,
      barrierColor: isLightTheme ? MyColors.black.withValues(alpha: 0.75) : MyColors.black.withValues(alpha: 0.75),
    ),
    primaryColorLight: MyColors.primary,
    primaryColorDark: MyColors.primaryDark,
    expansionTileTheme: ExpansionTileThemeData(
      collapsedIconColor: isLightTheme ? MyColors.textPrimary : MyColors.textPrimaryDark,
      textColor: isLightTheme ? MyColors.secondary : MyColors.secondaryDark,
      collapsedTextColor: isLightTheme ? MyColors.secondary : MyColors.secondaryDark,
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all<Color>(
        isLightTheme
            ? MyColors.white
            : MyColors.black,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: isLightTheme ? MyColors.primary : MyColors.primaryDark,
    ),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
        alignment: Alignment.center,
        foregroundColor: WidgetStateProperty.resolveWith((state) =>
        isLightTheme? MyColors.primary : MyColors.primaryDark),
        iconColor: WidgetStateProperty.all<Color>(
          isLightTheme
              ? MyColors.textPrimary
              : MyColors.textPrimaryDark,
        ),
      ),
    ),
    scaffoldBackgroundColor: isLightTheme ? MyColors.background : MyColors.backgroundDark,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isLightTheme ? MyColors.foreground : MyColors.upBackgroundDark,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: isLightTheme ? MyColors.primary : MyColors.primaryDark,
      unselectedItemColor: isLightTheme ? MyColors.hint : MyColors.hintDark,
      selectedLabelStyle: TextStyle(
        fontFamily: Fonts.poppins,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: isLightTheme ? MyColors.primary : MyColors.primaryDark,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: Fonts.poppins,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: isLightTheme ? MyColors.hint : MyColors.hintDark,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: isLightTheme ? MyColors.background : MyColors.backgroundDark,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(
        color: isLightTheme ? MyColors.textPrimary : MyColors.textPrimaryDark,
      ),
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w600,
        fontFamily: Fonts.poppins,
        color: isLightTheme ? MyColors.textPrimary : MyColors.textPrimaryDark,
        fontSize: 18.sp,
      ),
    ),
    fontFamily: Fonts.poppins,
  );
}
