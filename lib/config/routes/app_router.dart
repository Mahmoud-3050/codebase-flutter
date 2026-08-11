import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import '../../features/splash/presentation/navigation/router.dart' as splash;
export '../../features/splash/presentation/navigation/router.dart' hide $appRoutes;

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      // Example redirect logic can stay here
      return null;
    },
    routes: [
      ...splash.$appRoutes,
      // Combine all feature-specific generated routes
    ],
  );
}
