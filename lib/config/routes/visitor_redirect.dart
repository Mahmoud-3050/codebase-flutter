import 'package:flutter/foundation.dart';

import '../../core/utils/enums.dart';
import 'app_routes.dart';

/// Synchronous visitor state for [GoRouter] redirects.
///
/// Registered in [ServiceLocator.init]. Callers publish a [UserType] only
/// after the matching storage write has succeeded. Until the first publish,
/// protected routes wait on splash.
class VisitorRedirect extends ChangeNotifier {
  UserType? type;
  String? _pendingLocation;

  void publish(UserType value) {
    type = value;
    notifyListeners();
  }

  void remember(String location) {
    _pendingLocation = location;
  }

  String? takePending() {
    final String? location = _pendingLocation;
    _pendingLocation = null;
    return location;
  }
}

/// Routes a signed-out visitor cannot open directly.
bool isProtectedLocation(String path) {
  return path == AppRoutes.home || path == AppRoutes.studentProfile;
}

/// `go_router` redirect for the current visitor.
///
/// A missing [type] sends every route except splash back to splash, and
/// remembers the path so sign-in can restore it. [UserType.firstOpen] cannot
/// open a protected route.
String? redirectForVisitor({
  required UserType? type,
  required String path,
  required void Function(String location) remember,
}) {
  if (type == null) {
    if (path == AppRoutes.splash) {
      return null;
    }
    if (isProtectedLocation(path)) {
      remember(path);
    }
    return AppRoutes.splash;
  }
  if (type == UserType.firstOpen && isProtectedLocation(path)) {
    remember(path);
    return AppRoutes.welcome;
  }
  return null;
}
