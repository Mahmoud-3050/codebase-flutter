import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// ScreenUtil draft sizes per form factor and [Orientation].
///
/// Form factor uses shortest side so a phone in landscape stays mobile.
/// Desktop uses window width so a wide browser/desktop frame is not a tablet.
enum AppDesignSize {
  mobile(portrait: Size(393, 852), landscape: Size(852, 393)),
  tablet(portrait: Size(768, 1024), landscape: Size(1024, 768)),
  desktop(portrait: Size(1024, 1440), landscape: Size(1440, 1024));

  const AppDesignSize({required this.portrait, required this.landscape});

  final Size portrait;
  final Size landscape;

  static const double tabletMinShortestSide = 600;
  static const double desktopMinWidth = 1200;

  Size designSizeFor(Orientation orientation) => switch (orientation) {
    .landscape => landscape,
    .portrait => portrait,
  };

  static bool rebuildFactor(MediaQueryData old, MediaQueryData data) {
    return RebuildFactors.size(old, data) ||
        RebuildFactors.orientation(old, data);
  }

  static Size resolve(BoxConstraints constraints) {
    final orientation = orientationOf(constraints);
    return fromConstraints(constraints).designSizeFor(orientation);
  }

  static Orientation orientationOf(BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth || !constraints.hasBoundedHeight) {
      return Orientation.portrait;
    }
    return constraints.maxWidth > constraints.maxHeight
        ? .landscape
        : .portrait;
  }

  static AppDesignSize fromConstraints(BoxConstraints constraints) {
    if (!constraints.hasBoundedWidth) return mobile;

    if (constraints.maxWidth >= desktopMinWidth) return desktop;

    final shortestSide = constraints.hasBoundedHeight
        ? constraints.biggest.shortestSide
        : constraints.maxWidth;
    if (shortestSide >= tabletMinShortestSide) return tablet;

    return mobile;
  }
}
