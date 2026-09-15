import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/themes.dart';

class AppDivider extends StatelessWidget {
  final double? height;
  const AppDivider({this.height, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: height ?? 1.h, color: context.colors.divider);
  }
}
