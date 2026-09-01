import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../pages/student_profile_screen.dart';

part 'router.g.dart';

@TypedGoRoute<StudentProfileRoute>(
  path: AppRoutes.studentProfile,
  name: AppRoutes.studentProfile,
)
class StudentProfileRoute extends GoRouteData with $StudentProfileRoute {
  const StudentProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const StudentProfileScreen();
}

extension StudentProfileNavigation on BuildContext {
  void goStudentProfile() => const StudentProfileRoute().go(this);

  Future<T?> pushStudentProfile<T>() =>
      const StudentProfileRoute().push<T>(this);
}
