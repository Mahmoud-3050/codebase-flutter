import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:themes/themes.dart';

import 'enums.dart';

String _padTwoDigits(int value) => value.toString().padLeft(2, '0');

extension DateTimeExtension on DateTime {
  String get displayFormat =>
      '$year-${_padTwoDigits(month)}-${_padTwoDigits(day)}';

  String get displayTimeFormat =>
      '$year-${_padTwoDigits(month)}-${_padTwoDigits(day)} '
      '${_padTwoDigits(hour)}:${_padTwoDigits(minute)}:00';

  String get displayFormatYearMonth => '$year-${_padTwoDigits(month)}';
}

extension IntExtension on int {
  String get divideByK {
    String numStr = toString();
    if (numStr.length < 4) return numStr;
    if (numStr.length >= 4 && numStr.length <= 6) {
      int start = numStr.length - 1 - 2;
      return '${numStr.substring(0, start)},${numStr.substring(start, numStr.length)}';
    }
    if (numStr.length >= 7 && numStr.length <= 9) {
      int start = numStr.length - 1 - 2;
      return '${numStr.substring(0, start - 3)},${numStr.substring(start - 3, start)},${numStr.substring(start, numStr.length)}';
    }
    return numStr;
  }
}

extension StringExtension on String {
  String get capitalizeFirst {
    if (length > 1) {
      return '${this[0].toUpperCase()}${substring(1)}';
    }
    if (length == 1) {
      return toUpperCase();
    }
    return this;
  }

  Future<void> get launcherUrl async {
    Uri? uri = Uri.tryParse(this);
    if (uri == null) {
      throw Exception('Could not launch $this');
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      throw Exception('Could not launch $this');
    }
  }

  Future<bool> get copyText async {
    try {
      final ClipboardData data = ClipboardData(text: this);
      await Clipboard.setData(data);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

extension FormDataExtension on FormData {
  String get toPrint {
    Map<String, dynamic> result = {};
    for (final item in fields) {
      result[item.key] = item.value;
    }
    for (final item in files) {
      result[item.key] = item.value;
    }
    return result.toString();
  }
}

extension UserTypeExtension on UserType {
  static UserType fromString(String value) =>
      UserType.values.firstWhere((UserType element) => element.name == value,
          orElse: () => UserType.firstOpen);
}

extension AppUpdateTypeExtension on AppUpdateType {
  static AppUpdateType fromString(String value) => AppUpdateType.values
      .firstWhere((AppUpdateType element) => element.name == value,
          orElse: () => AppUpdateType.immediately);
}

extension ColorFilterExtension on ColorFilter {
  static ColorFilter getFocusColor(FocusNode focusNode) {
    return ColorFilter.mode(
      focusNode.hasFocus
          ? Themes.instance.colors.primary
          : Themes.instance.colors.hint,
      BlendMode.srcIn,
    );
  }

  static ColorFilter setColor(Color color) {
    return ColorFilter.mode(
      color,
      BlendMode.srcIn,
    );
  }
}

extension CircularProgressIndicatorExtension on CircularProgressIndicator {
  CircularProgressIndicator get appLoading {
    if (color != null) {
      return CircularProgressIndicator(
        key: key,
        strokeWidth: 2.w,
        valueColor: valueColor,
        color: color,
        backgroundColor: backgroundColor,
        semanticsLabel: semanticsLabel,
        semanticsValue: semanticsValue,
        value: value,
        strokeAlign: strokeAlign,
        strokeCap: strokeCap,
      );
    }
    return CircularProgressIndicator.adaptive(
      key: key,
      strokeWidth: 2.w,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
      semanticsLabel: semanticsLabel,
      semanticsValue: semanticsValue,
      value: value,
      strokeAlign: strokeAlign,
      strokeCap: strokeCap,
    );
  }
}

extension TextEditingControllerExtension on TextEditingController {
  void get fixCursorErrorOfLastIndex {
    addListener(() {
      if (selection ==
          TextSelection.fromPosition(
            TextPosition(
              offset: text.length - 1,
            ),
          )) {
        selection = TextSelection.fromPosition(
          TextPosition(
            offset: text.length,
          ),
        );
      }
    });
  }
}
