import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../injection_container.dart';
import '../../../config/language/strings.dart';
import '../../utils/values/text_styles.dart';
import '../app_outlined_button.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Strings.deleteAccount,
            style: TextStyles.semiBold18(color: colors.error),
          ),
          SizedBox(height: 16.h),
          Text(
            '${Strings.deleteAccountWarning}.',
            style: TextStyles.regular14(color: colors.textPrimary),
            maxLines: 3,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  text: Strings.delete,
                  textStyle: TextStyles.regular12(color: colors.error),
                  borderColor: colors.error,
                  backgroundColor: colors.foreground,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  text: Strings.no,
                  textStyle: TextStyles.regular12(color: colors.primary),
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

class ConfirmDeleteAccountDialog extends StatelessWidget {
  const ConfirmDeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            Strings.confirmDeleteAccount,
            style: TextStyles.semiBold18(color: colors.error),
          ),
          SizedBox(height: 16.h),
          Text(
            Strings.areYouSureDeleteAccount,
            style: TextStyles.regular14(color: colors.textPrimary),
            maxLines: 3,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  text: Strings.yes,
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
                  text: Strings.no,
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
