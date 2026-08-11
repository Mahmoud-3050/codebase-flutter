import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../injection_container.dart';
import '../../utils/values/text_styles.dart';
import '../app_divider.dart';

class ModalBottomSheetScaffold extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget child;
  final Widget? icon;

  const ModalBottomSheetScaffold({
    required this.title,
    required this.child, this.subTitle = '',
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24.r),
          topEnd: Radius.circular(24.r),
        ),
        color: colors.foreground,
      ),
      child: Wrap(
        children: [
          ///AppBar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon?? IconButton(
                onPressed: (){},
                icon: Icon(
                  Icons.close_rounded,
                  size: 32.r,
                  color: Colors.transparent,
                ),
              ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.medium18(color: colors.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.close_rounded,
                  size: 32.r,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          subTitle.isNotEmpty
              ? Center(
                child: Text(
                  subTitle,
                  style: TextStyles.regular14(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ) : const SizedBox(),
          SizedBox(height: 32.h),
          const AppDivider(),
          ///Body
          child,
        ],
      ),
    );
  }

}
