import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:themes/themes.dart';

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
    final colors = context.colors;
    return Padding(
      padding: .symmetric(horizontal: 16.w),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          SvgPicture.asset(
                iconSvg,
                width: 120.w,
                height: 120.h,
                colorFilter: ColorFilterExtension.setColor(colors.textPrimary),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.5, end: 1.0, delay: 150.ms, duration: 350.ms)
              .scaleXY(begin: 1.1, end: 1.0, delay: 500.ms, duration: 150.ms)
              .shake(delay: 500.ms, duration: 500.ms),
          SizedBox(height: 12.h),
          Text(
            title,
            style: TextStyles.of(size: 18, weight: .w600),
            textAlign: .center,
            maxLines: 5,
          ),
          SizedBox(height: 6.h),
          Text(
            message,
            style: TextStyles.of(size: 13, color: colors.textSecondary),
            textAlign: .center,
            maxLines: 10,
          ),
        ],
      ),
    );
  }
}
