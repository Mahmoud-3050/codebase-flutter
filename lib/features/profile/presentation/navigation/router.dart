import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/feature_scope.dart';
import '../../../../injection_container.dart';
import '../../profile_injection.dart';
import '../controller/get_student_profile/get_student_profile_cubit.dart';
import '../controller/update_student_profile/update_student_profile_cubit.dart';
import '../pages/student_profile_screen.dart';

part 'router.g.dart';

const String _studentProfileScopeName = 'StudentProfileScope';

@TypedGoRoute<StudentProfileRoute>(
  path: AppRoutes.studentProfile,
  name: AppRoutes.studentProfile,
)
class StudentProfileRoute extends GoRouteData with $StudentProfileRoute {
  const StudentProfileRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeatureScope(
      scopeName: _studentProfileScopeName,
      registrations: const [
        registerProfileDataLayer,
        registerGetStudentProfile,
        registerUpdateStudentProfile,
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ServiceLocator.instance<GetStudentProfileCubit>()),
          BlocProvider(
            create: (_) => ServiceLocator.instance<UpdateStudentProfileCubit>(),
          ),
        ],
        child: const StudentProfileScreen(),
      ),
    );
  }
}

extension StudentProfileNavigation on BuildContext {
  void goStudentProfile() => const StudentProfileRoute().go(this);

  Future<T?> pushStudentProfile<T>() => const StudentProfileRoute().push<T>(this);
}
