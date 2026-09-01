import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/extensions.dart';
import '../../utils/values/text_styles.dart';

class LoadingDialog extends StatelessWidget {
  final String? title;
  const LoadingDialog({
    this.title,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 72.h),
      child: Builder(
        builder: (context) {
          if (title != null) {
            return Wrap(
              direction: Axis.vertical,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runAlignment: WrapAlignment.center,
              children: [
                SizedBox(
                  width: 64.w,
                  height: 64.h,
                  child: Center(
                    child: const CircularProgressIndicator().appLoading,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  title!,
                  style: TextStyles.of(size: 16, weight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            );
          }
          return SizedBox(
            width: 64.w,
            height: 64.h,
            child: Center(
              child: const CircularProgressIndicator().appLoading,
            ),
          );
        },
      ),
    );
  }
}
