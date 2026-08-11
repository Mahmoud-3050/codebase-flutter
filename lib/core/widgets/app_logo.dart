import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/theme/presentation/cubit/theme_cubit/theme_cubit.dart';
import '../utils/values/assets.dart';
import 'app_image.dart';

class AppLogo extends StatelessWidget {
  final double? width, height;

  const AppLogo({
    this.width,
    this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (BuildContext context, ThemeState state){
        return AppImage.asset(
          imageAsset: context.read<ThemeCubit>().isDarkMode
              ? Assets.imagesLogoSWhiteShadow
              : Assets.imagesLogoSBlack,
          width: width ?? 150.w,
          height: height ?? 150.h,
        );
      },
    );
  }
}
