import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../injection_container.dart';
import 'app_routes.dart';
import 'visitor_redirect.dart';
import '../../features/auth/presentation/navigation/router.dart' as auth;
import '../../features/home/presentation/navigation/router.dart' as home;
import '../../features/profile/presentation/navigation/router.dart' as profile;
import '../../features/splash/presentation/navigation/router.dart' as splash;

export '../../features/auth/presentation/navigation/router.dart'
    hide $appRoutes;
export '../../features/home/presentation/navigation/router.dart'
    hide $appRoutes;
export '../../features/profile/presentation/navigation/router.dart'
    hide $appRoutes;
export '../../features/splash/presentation/navigation/router.dart'
    hide $appRoutes;

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: visitorRedirect,
    redirect: (BuildContext context, GoRouterState state) {
      return redirectForVisitor(
        type: visitorRedirect.type,
        path: state.uri.path,
        remember: visitorRedirect.remember,
      );
    },
    routes: <RouteBase>[
      ...splash.$appRoutes,
      ...auth.$appRoutes,
      ...home.$appRoutes,
      ...profile.$appRoutes,
    ],
  );
}
