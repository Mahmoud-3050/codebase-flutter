import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/routes/app_routes.dart';
import '../pages/splash_screen.dart';

part 'router.g.dart';


@TypedGoRoute<SplashRoute>(path: AppRoutes.splash, name: AppRoutes.splash)
class SplashRoute extends GoRouteData with $SplashRoute {

  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const SplashScreen();
}


extension SplashNavigation on BuildContext {  void goSplash() => const SplashRoute().go(this);
  void pushSplash() => const SplashRoute().push(this);
}
