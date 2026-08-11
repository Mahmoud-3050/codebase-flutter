import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<dynamic> showAppDialog({
  required BuildContext context,
  required Widget child,
  double? borderRadius,
  Color? backgroundColor,
  bool isDismissible = true,
  EdgeInsets? insetPadding,
}) {
  return showDialog<dynamic>(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: backgroundColor,
        insetPadding: insetPadding?? EdgeInsets.symmetric(horizontal: 40.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
        ),
        child: PopScope(
          canPop: isDismissible,
          child: child,
        ),
      );
    },
  );
}
