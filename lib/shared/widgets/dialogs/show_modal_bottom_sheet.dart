import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<dynamic> showAppModalBottomSheet({
  required BuildContext context,
  required Widget child,
  double? borderRadius,
  bool isDismissible = true,
  double? height,
}) {
  return showModalBottomSheet<dynamic>(
    context: context,
    isScrollControlled: true,
    enableDrag: isDismissible,
    isDismissible: isDismissible,
    shape: RoundedRectangleBorder(
      borderRadius: .circular(borderRadius ?? 20.r),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: .only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: PopScope(
          canPop: isDismissible,
          child: Builder(
            builder: (BuildContext context) {
              if (height == null) {
                return child;
              }
              return SizedBox(height: height, child: child);
            },
          ),
        ),
      );
    },
  );
}
