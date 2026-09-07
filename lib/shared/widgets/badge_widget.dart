import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:language/language.dart';
import 'package:themes/themes.dart';

import '../../../core/utils/values/text_styles.dart';

class BadgeWidget extends StatelessWidget {
  final int count;
  final Widget child;
  final double? topPosition;
  final double? endPosition;
  final bool showZero;
  const BadgeWidget({
    required this.count,
    required this.child,
    this.topPosition,
    this.endPosition,
    this.showZero = true,
    super.key,
  });


  String _getBadgeContent(int count) {
    if (count > 99) {
      if(Language.instance.isArabic){
        return '99+';
      }
      return '+99';
    }
    return count.toString();
  }
  @override
  Widget build(BuildContext context) {
    if(!showZero && count == 0){
      return child;
    }
    return badges.Badge(
      position: badges.BadgePosition.topEnd(
        top: topPosition ?? (count > 9 ? -4.h : -6.h),
        end: endPosition ?? (count > 9 ? -3.w : -3.w),
      ),
      badgeContent: Text(
        _getBadgeContent(count),
        style: TextStyles.of(size: 11, color: context.colors.white),
        textAlign: .center,
        textHeightBehavior: const TextHeightBehavior(
          applyHeightToLastDescent: false,
          applyHeightToFirstAscent: false,
        ),
      ),
      badgeAnimation: const .scale(
        colorChangeAnimationDuration: Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn,
        colorChangeAnimationCurve: Curves.easeInCubic,
      ),
      badgeStyle: badges.BadgeStyle(
        elevation: 0,
        padding: .only(
          top: count > 9 ? 6.r : 6.r,
          bottom: count > 9 ? 4.r : 4.r,
          left: count > 9 ? 5.5.r : 6.r,
          right: count > 9 ? 5.5.r : 6.r,
        ),
        badgeColor: context.colors.error,
      ),
      child: child,
    );
  }
}
