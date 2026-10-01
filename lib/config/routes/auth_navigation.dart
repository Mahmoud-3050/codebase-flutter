import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/enums.dart';
import '../../features/auth/presentation/navigation/router.dart';
import '../../features/home/presentation/navigation/router.dart';
import '../../injection_container.dart';
import 'visitor_redirect.dart';

void openAuthenticatedDestination(
  BuildContext context, {
  bool sessionExpired = false,
}) {
  visitorRedirect.publish(UserType.loggedIn);
  _goToPendingOrHome(context, sessionExpired: sessionExpired);
}

void openGuestDestination(BuildContext context, {bool sessionExpired = false}) {
  visitorRedirect.publish(UserType.guest);
  _goToPendingOrHome(context, sessionExpired: sessionExpired);
}

void openSignedOut(BuildContext context) {
  visitorRedirect.publish(UserType.guest);
  const WelcomeRoute().go(context);
}

void publishFirstOpen() {
  visitorRedirect.publish(UserType.firstOpen);
}

/// Splash uses the stored visitor type and restores a protected deep link.
void openResolvedDestination(
  BuildContext context,
  UserType type, {
  bool sessionExpired = false,
}) {
  switch (type) {
    case UserType.firstOpen:
      publishFirstOpen();
      const WelcomeRoute().go(context);
    case UserType.loggedIn:
      openAuthenticatedDestination(context, sessionExpired: sessionExpired);
    case UserType.guest:
      openGuestDestination(context, sessionExpired: sessionExpired);
  }
}

void _goToPendingOrHome(BuildContext context, {bool sessionExpired = false}) {
  final String? pending = visitorRedirect.takePending();
  if (pending != null && isProtectedLocation(pending)) {
    context.go(pending);
    return;
  }
  HomeRoute(sessionExpired: sessionExpired).go(context);
}
