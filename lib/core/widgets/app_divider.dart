import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../injection_container.dart';

class AppDivider extends StatefulWidget {
  const AppDivider({super.key});

  @override
  State<AppDivider> createState() => _AppDividerState();
}

class _AppDividerState extends State<AppDivider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.h,
      color: colors.divider,
    );
  }
}
