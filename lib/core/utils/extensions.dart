import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:themes/themes.dart';



extension DateTimeExtension on DateTime {
  String _padTwoDigits(int value) => value.toString().padLeft(2, '0');
  
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
      await launchUrl(uri, mode: .externalApplication);
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

extension ColorFilterExtension on ColorFilter {
  static ColorFilter getFocusColor(FocusNode focusNode) {
    return ColorFilter.mode(
      focusNode.hasFocus
          ? Themes.instance.colors.primary
          : Themes.instance.colors.hint,
      .srcIn,
    );
  }

  static ColorFilter setColor(Color color) {
    return ColorFilter.mode(color, .srcIn);
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
      if (selection == .fromPosition(TextPosition(offset: text.length - 1))) {
        selection = .fromPosition(TextPosition(offset: text.length));
      }
    });
  }
}

/// ScreenUtil gaps. On `num` so integer literals work (`24.hGap`).
extension GapExtension on num {
  /// Horizontal space: [SizedBox] width scaled with `.w`.
  SizedBox get wGap => SizedBox(width: w);

  /// Vertical space: [SizedBox] height scaled with `.h`.
  SizedBox get hGap => SizedBox(height: h);

  /// Horizontal sliver space (e.g. horizontal [CustomScrollView]).
  SliverToBoxAdapter get wSliverGap =>
      SliverToBoxAdapter(child: SizedBox(width: w));

  /// Vertical sliver space (e.g. vertical [CustomScrollView]).
  SliverToBoxAdapter get hSliverGap =>
      SliverToBoxAdapter(child: SizedBox(height: h));
}

/// ScreenUtil insets. `h`/start/end use `.w`; `v`/top/bottom use `.h`.
/// `Paddings.symmetric(h: 16, v: 20)` → `horizontal: 16.w, vertical: 20.h`.
extension Paddings on EdgeInsetsGeometry {
  static EdgeInsetsDirectional symmetric({num h = 0, num v = 0}) {
    return EdgeInsetsDirectional.symmetric(horizontal: h.w, vertical: v.h);
  }

  static EdgeInsetsDirectional only({
    num start = 0,
    num top = 0,
    num end = 0,
    num bottom = 0,
  }) {
    return EdgeInsetsDirectional.only(
      start: start.w,
      top: top.h,
      end: end.w,
      bottom: bottom.h,
    );
  }
}

extension ObjectParsingX on Object? {
  // ---- shared raw parsers (single source of truth per type) ----
  num? _asNum() => num.tryParse(this?.toString() ?? '');

  bool? _asBool() {
    final value = this;
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value == 1;

    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
    return null;
  }

  // ---- int ----
  int toIntOrZero() => _asNum()?.toInt() ?? 0;
  int? toIntOrNull() => _asNum()?.toInt();

  // ---- double ----
  double toDoubleOrZero() => _asNum()?.toDouble() ?? 0.0;
  double? toDoubleOrNull() => _asNum()?.toDouble();

  // ---- String ----
  String toStringOrEmpty() => this == null ? '' : toString();

  // ---- bool ----
  bool toBoolOrFalse() => _asBool() ?? false;
  bool? toBoolOrNull() => _asBool();
}
