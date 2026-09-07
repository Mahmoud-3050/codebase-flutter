import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:themes/themes.dart';

import '../../config/language/strings.dart';
import '../../core/utils/extensions.dart';
import '../../core/utils/values/assets.dart';
import '../../core/utils/values/text_styles.dart';

class EmptyWidget extends StatelessWidget {
  final String? iconSvgPath;
  final String? title;
  final String? message;

  const EmptyWidget({this.iconSvgPath, this.title, this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: .symmetric(horizontal: 20.w),
      child: Column(
        mainAxisAlignment: .center,
        children: [
          // Icon
          SvgPicture.asset(
                iconSvgPath ?? Assets.emptyWhiteBox,
                width: 120.w,
                height: 120.h,
                colorFilter: ColorFilterExtension.setColor(colors.textPrimary),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.5, end: 1.0, delay: 150.ms, duration: 350.ms)
              .scaleXY(begin: 1.1, end: 1.0, delay: 500.ms, duration: 150.ms)
              .shake(delay: 500.ms, duration: 350.ms),
          24.hGap,
          // Title
          ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 0.85.sw),
                child: Text(
                  title ?? Strings.noDataFound,
                  style: TextStyles.of(size: 18, weight: .w600),
                  textAlign: .center,
                  overflow: .visible,
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .scaleXY(begin: 0.5, end: 1.0, delay: 150.ms, duration: 350.ms)
              .scaleXY(begin: 1.1, end: 1.0, delay: 500.ms, duration: 150.ms),
          // Message
          if (message != null && message!.isNotEmpty) ...[
            16.hGap,
            ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 0.85.sw),
                  child: Text(
                    message!,
                    style: TextStyles.of(size: 13, color: colors.textSecondary),
                    textAlign: .center,
                    overflow: .visible,
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .scaleXY(begin: 0.5, end: 1.0, delay: 150.ms, duration: 350.ms)
                .scaleXY(begin: 1.1, end: 1.0, delay: 500.ms, duration: 150.ms),
          ],
        ],
      ),
    );
  }
}
