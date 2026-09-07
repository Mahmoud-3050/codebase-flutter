import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

class BaseContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final Color? color;

  const BaseContainer({
    required this.child,
    this.padding,
    this.margin,
    this.radius,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      padding: padding ?? EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? context.colors.foreground,
        borderRadius: .circular(radius ?? 16.r),
      ),
      child: child,
    );
  }
}
