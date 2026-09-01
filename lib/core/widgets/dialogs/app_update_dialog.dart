import 'package:flutter/material.dart';
import 'package:store_redirect/store_redirect.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../../../config/language/strings.dart';
import '../../../config/themes/extra_colors.dart';
import '../../utils/values/text_styles.dart';
import '../app_elevated_button.dart';
import '../app_logo.dart';

class AppUpdateDialog extends StatelessWidget {
  final String newVersion;

  const AppUpdateDialog({required this.newVersion, super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      children: [
        Stack(children: <Widget>[_content(colors), _appLogo(colors)]),
      ],
    );
  }

  Widget _appLogo(ThemeColors colors) => Positioned(
    left: 0,
    right: 0,
    child: Container(
      width: 100.w,
      height: 100.h,
      decoration: BoxDecoration(
        color: colors.foreground,
        shape: .circle,
        border: .all(color: colors.primary, width: 2.w),
        boxShadow: [BoxShadow(color: colors.secondary, blurRadius: 16.r)],
      ),
      child: Center(
        child: AppLogo(width: 50.w, height: 50.h),
      ),
    ),
  );

  Widget _content(ThemeColors colors) => Container(
    margin: EdgeInsetsDirectional.only(top: 64.h),
    padding: EdgeInsetsDirectional.only(
      start: 24.w,
      end: 24.w,
      top: 64.h,
      bottom: 32.h,
    ),
    decoration: BoxDecoration(
      color: colors.foreground,
      borderRadius: .all(.circular(32.r)),
    ),
    child: Column(
      mainAxisAlignment: .center,
      children: <Widget>[
        _textHeader(colors),
        SizedBox(height: 16.h),
        _textBody(colors),
        SizedBox(height: 32.h),
        _updateButton,
      ],
    ),
  );

  Widget _textHeader(ThemeColors colors) => Row(
    children: <Widget>[
      Expanded(
        child: Text(
          '${Strings.newVersion}!',
          style: TextStyles.of(size: 18, weight: .w600),
          maxLines: 1,
        ),
      ),
      SizedBox(width: 4.w),
      Text(
        'v$newVersion',
        style: TextStyles.of(
          size: 18,
          weight: .w600,
          color: colors.yellow.withValues(alpha: 0.9),
        ),
        maxLines: 1,
      ),
    ],
  );

  Widget _textBody(ThemeColors colors) => Text(
    Strings.updateAppMsg,
    style: TextStyles.of(size: 14, color: colors.textSecondary),
    textAlign: .start,
    maxLines: 10,
  );

  Widget get _updateButton => Center(
    child: AppElevatedButton(
      text: Strings.update,
      onPressed: () async {
        StoreRedirect.redirect(
          androidAppId: 'com.sahalat.android',
          iOSAppId: '6737917009',
        );
      },
    ),
  );
}
