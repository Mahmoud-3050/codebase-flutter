import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../config/themes/extra_colors.dart';

Color get _textColor => colors.textPrimary;

abstract class TextStyles {
  //region:: Light
  static TextStyle light10({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 10.sp,
        fontWeight: FontWeight.w300,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle light12({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w300,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle light13({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 13.sp,
        fontWeight: FontWeight.w300,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle light14({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w300,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle light15({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w300,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle light16({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w300,
        overflow: TextOverflow.ellipsis,
      );

  //endregion

  //region:: Regular
  static TextStyle regular20({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular18({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular17({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 17.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular16({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular15({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular14({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular13({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle regular12({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );
  static TextStyle regular10({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 10.sp,
        fontWeight: FontWeight.w400,
        overflow: TextOverflow.ellipsis,
      );

  //endregion

  //region:: Medium
  static TextStyle medium24({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 24.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium22({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 22.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium20({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium18({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium17({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 17.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium16({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium15({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium14({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium13({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 13.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium12({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium10({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle medium9({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 9.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );
  static TextStyle medium8({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 8.sp,
        fontWeight: FontWeight.w500,
        overflow: TextOverflow.ellipsis,
      );

  //endregion

  //region:: SemiBold
  static TextStyle semiBold24({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 24.sp,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle semiBold20({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle semiBold18({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle semiBold16({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle semiBold14({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
        overflow: TextOverflow.ellipsis,
      );

  //endregion

  //region:: Bold
  static TextStyle bold32({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold24({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold22({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold20({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold19({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 19.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold18({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold17({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 17.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold16({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold15({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle bold14({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        overflow: TextOverflow.ellipsis,
      );

//endregion

  //region:: ExtraBold
  static TextStyle extraBold20({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle extraBold19({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 19.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle extraBold18({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 18.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle extraBold17({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 17.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle extraBold16({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 16.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle extraBold15({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

  static TextStyle extraBold14({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 14.sp,
        fontWeight: FontWeight.w800,
        overflow: TextOverflow.ellipsis,
      );

//endregion

  //region:: UnderLine Regular
  static TextStyle underlineRegular20({Color? color}) => TextStyle(
        color: color ?? _textColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.w400,
        decoration: TextDecoration.underline,
        overflow: TextOverflow.ellipsis,
      );
//endregion

  //region:: LineThrough Medium
  static TextStyle lineThroughMedium15({Color? color, bool? isArabic}) =>
      TextStyle(
        color: color ?? _textColor,
        fontSize: 15.sp,
        fontWeight: FontWeight.w500,
        // decorationStyle: TextDecorationStyle,
        decorationColor: color ?? _textColor,
        decorationThickness: isArabic == true ? 15.sp + 4.sp : null,
        decoration: TextDecoration.lineThrough,
        overflow: TextOverflow.ellipsis,
      );
//endregion
}
