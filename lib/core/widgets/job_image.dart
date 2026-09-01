import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:themes/themes.dart';

import '../utils/extensions.dart';
import '../utils/values/assets.dart';
import 'app_image.dart';

class JobImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;

  const JobImage({
    required this.imageUrl,
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return imageUrl != null && imageUrl?.isNotEmpty == true
        ? AppImage.network(
      imageUrl: imageUrl,
      width: width ?? 70.r,
      height: height ?? 70.r,
      isCircle: true,
      fit: BoxFit.cover,
    )
        : SvgPicture.asset(
      Assets.iconsBuilding,
      width: width ?? 70.r,
      height: height ?? 70.r,
      colorFilter: ColorFilterExtension.setColor(context.colors.textPrimary),
    );
  }
}
