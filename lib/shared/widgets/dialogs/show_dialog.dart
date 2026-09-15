import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';

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
        insetPadding:
            insetPadding ?? .symmetric(horizontal: 40.w, vertical: 24.h),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(borderRadius ?? 12.r),
        ),
        child: PopScope(canPop: isDismissible, child: child),
      );
    },
  );
}
