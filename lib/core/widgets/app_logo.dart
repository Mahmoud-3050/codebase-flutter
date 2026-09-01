import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../utils/values/assets.dart';
import 'app_image.dart';

class AppLogo extends StatelessWidget {
  final double? width, height;

  const AppLogo({this.width, this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return AppImage.asset(
      imageAsset: context.isDarkTheme
          ? Assets.imagesLogoSWhiteShadow
          : Assets.imagesLogoSBlack,
      width: width ?? 150.w,
      height: height ?? 150.h,
    );
  }
}
