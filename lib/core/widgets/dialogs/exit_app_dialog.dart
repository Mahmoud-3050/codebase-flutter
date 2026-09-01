import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../../config/language/strings.dart';
import '../../utils/values/text_styles.dart';
import '../app_outlined_button.dart';

class ExitAppDialog extends StatelessWidget {
  const ExitAppDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: .symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        mainAxisSize: .min,
        children: [
          Text(
            Strings.confirmExit,
            style: TextStyles.of(size: 18, weight: .w600),
          ),
          SizedBox(height: 24.h),
          Text(
            '${Strings.exitAppContent}?',
            style: TextStyles.of(size: 14),
            maxLines: 3,
          ),
          SizedBox(height: 32.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  text: Strings.exit,
                  borderColor: colors.error,
                  textColor: colors.error,
                  backgroundColor: colors.foreground,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  text: Strings.cancel,
                  backgroundColor: colors.foreground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
