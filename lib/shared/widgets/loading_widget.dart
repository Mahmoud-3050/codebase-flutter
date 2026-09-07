import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/utils/extensions.dart';

class LoadingWidget extends StatelessWidget {
  final double size;
  const LoadingWidget({this.size = 48, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size.r,
      child: Center(
      child: const CircularProgressIndicator().appLoading,
    ),
    );
  }
}
