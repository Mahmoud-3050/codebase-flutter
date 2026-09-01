import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:themes/themes.dart';

import '../utils/extensions.dart';
import '../utils/values/assets.dart';
import 'app_image.dart';

class ProfilePicture extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final String? placeholderSvg;
  final Color? placeholderColor;
  final Color? backgroundColor;

  const ProfilePicture({
    required this.imageUrl,
    this.width,
    this.height,
    this.placeholderSvg,
    this.placeholderColor,
    this.backgroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (imageUrl != null && imageUrl != '') {
          return AppImage.network(
            imageUrl: imageUrl,
            width: width ?? 80.w,
            height: height ?? 80.h,
            isCircle: true,
            isCached: false,
          );
        }
        if (backgroundColor != null) {
          return Container(
            padding: .all(6.r),
            decoration: BoxDecoration(color: backgroundColor, shape: .circle),
            child: SvgPicture.asset(
              placeholderSvg ?? Assets.iconsUser,
              width: width ?? 80.w,
              height: height ?? 80.h,
              fit: .fill,
              colorFilter: ColorFilterExtension.setColor(
                placeholderColor ?? context.colors.textPrimary,
              ),
            ),
          );
        }
        return SvgPicture.asset(
          placeholderSvg ?? Assets.iconsUser,
          width: width ?? 80.w,
          height: height ?? 80.h,
          fit: .fill,
          colorFilter: ColorFilterExtension.setColor(
            placeholderColor ?? context.colors.textPrimary,
          ),
        );
      },
    );
  }
}
