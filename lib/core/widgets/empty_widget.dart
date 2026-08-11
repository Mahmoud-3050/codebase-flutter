import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../injection_container.dart';
import '../utils/extensions.dart';
import '../utils/values/text_styles.dart';

class EmptyWidget extends StatelessWidget {
  final String iconSvg;
  final String title;
  final String message;

  const EmptyWidget({
    required this.iconSvg,
    required this.title,
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            iconSvg,
            width: 120.w,
            height: 120.h,
            colorFilter: ColorFilterExtension.setColor(colors.textPrimary),
          ).animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.5, end: 1.0, delay: 150.ms, duration: 350.ms)
              .scaleXY(begin: 1.1, end: 1.0, delay: 500.ms, duration: 150.ms)
              .shake(delay: 500.ms, duration: 500.ms),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyles.semiBold18(color: colors.textPrimary),
            textAlign: TextAlign.center,
            maxLines: 5,
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: TextStyles.regular13(color: colors.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
