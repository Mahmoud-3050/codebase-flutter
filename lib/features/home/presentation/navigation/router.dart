import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/feature_scope.dart';
import '../../../../injection_container.dart';
import '../../../auth/auth_injection.dart';
import '../../../auth/presentation/controller/logout/logout_cubit.dart';
import '../pages/home_screen.dart';

part 'router.g.dart';

const String _homeScopeName = 'HomeScope';

@TypedGoRoute<HomeRoute>(path: AppRoutes.home, name: AppRoutes.home)
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute({this.sessionExpired = false});

  final bool sessionExpired;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeatureScope(
      scopeName: _homeScopeName,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerLogout,
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<LogoutCubit>(
            create: (_) => ServiceLocator.instance<LogoutCubit>(),
          ),
        ],
        child: HomeScreen(sessionExpired: sessionExpired),
      ),
    );
  }
}
