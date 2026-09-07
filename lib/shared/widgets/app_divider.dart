import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

class AppDivider extends StatelessWidget {
  final double? height;
  const AppDivider({this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: height ?? 1.h, color: context.colors.divider);
  }
}
