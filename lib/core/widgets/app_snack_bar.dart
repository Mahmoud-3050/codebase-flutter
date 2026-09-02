import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:themes/themes.dart';

import '../utils/extensions.dart';

void showAppSnackBar({
  required BuildContext context,
  required String message,
  required ToastType type,
  SnackBarBehavior? behavior = .floating,
  Duration duration = const Duration(milliseconds: 5000),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    _buildAppSnackBar(
      context: context,
      message: message,
      type: type,
      behavior: behavior,
      duration: duration,
    ),
  );
}

SnackBar _buildAppSnackBar({
  required BuildContext context,
  required String message,
  required ToastType type,
  required SnackBarBehavior? behavior,
  required Duration duration,
}) {
  return SnackBar(
    content: _buildContent(context, message, type),
    dismissDirection: .horizontal,
    padding: _padding,
    margin: _getMargin(context, behavior),
    backgroundColor: type.color,
    shape: RoundedRectangleBorder(borderRadius: .circular(16.r)),
    behavior: behavior,
    duration: duration,
    elevation: 0.0,
  );
}

Widget _buildContent(BuildContext context, String message, ToastType type) {
  final colors = context.colors;
  return Wrap(
    crossAxisAlignment: .center,
    children: <Widget>[
      Icon(type.icon, color: colors.white, size: 32.r),
      SizedBox(width: 8.w),
      Text(
        message,
        style: TextStyle(
          color: colors.white,
          fontSize: 13.sp,
          fontWeight: .w400,
          overflow: .clip,
        ),
      ),
    ],
  );
}

EdgeInsetsDirectional get _padding =>
    .symmetric(horizontal: 16.w, vertical: 8.h);

EdgeInsetsDirectional? _getMargin(
  BuildContext context,
  SnackBarBehavior? behavior,
) {
  if (behavior != .floating) {
    return null;
  }
  return Paddings.only(bottom: 16, start: 16, end: 16);
}

enum ToastType { success, error, warning, info }

extension ToastTypeColor on ToastType {
  Color get color {
    switch (this) {
      case .success:
        return _Colors.success;
      case .error:
        return _Colors.red;
      case .warning:
        return _Colors.warning;
      case .info:
        return _Colors.info;
    }
  }

  IconData get icon {
    switch (this) {
      case .success:
        return Icons.check_circle_rounded;
      case .error:
        return Icons.error_rounded;
      case .warning:
        return Icons.warning_rounded;
      case .info:
        return Icons.info_rounded;
    }
  }
}

abstract class _Colors {
  static const Color success = Color(0xFF10A94B);
  static const Color red = Color(0xFFE63D35);
  static const Color info = Color(0xFF296CAF);
  static const Color warning = Color(0xFFF7B313);
}
