import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../utils/values/text_styles.dart';
import '../app_divider.dart';

class ModalBottomSheetScaffold extends StatelessWidget {
  final String title;
  final String subTitle;
  final Widget child;
  final Widget? icon;

  const ModalBottomSheetScaffold({
    required this.title,
    required this.child,
    this.subTitle = '',
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      padding: .symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadiusDirectional.only(
          topStart: .circular(24.r),
          topEnd: .circular(24.r),
        ),
        color: colors.foreground,
      ),
      child: Wrap(
        children: [
          ///AppBar
          Row(
            mainAxisAlignment: .center,
            children: [
              icon ??
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.close_rounded,
                      size: 32.r,
                      color: Colors.transparent,
                    ),
                  ),
              Expanded(
                child: Text(
                  title,
                  style: TextStyles.of(size: 18, weight: .w500),
                  textAlign: .center,
                ),
              ),
              IconButton(
                onPressed: () {
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
                    style: TextStyles.of(size: 14, color: colors.textSecondary),
                    textAlign: .center,
                  ),
                )
              : const SizedBox(),
          SizedBox(height: 32.h),
          const AppDivider(),

          ///Body
          child,
        ],
      ),
    );
  }
}
