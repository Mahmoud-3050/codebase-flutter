// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
      $studentProfileRoute,
    ];

RouteBase get $studentProfileRoute => GoRouteData.$route(
      path: '/student-profile',
      name: '/student-profile',
      hasOverriddenOnExit: false,
      factory: $StudentProfileRoute._fromState,
    );

mixin $StudentProfileRoute on GoRouteData {
  static StudentProfileRoute _fromState(GoRouterState state) =>
      const StudentProfileRoute();

  @override
  String get location => GoRouteData.$location(
        '/student-profile',
      );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
