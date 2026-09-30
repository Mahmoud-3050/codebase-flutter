import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/feature_scope.dart';
import '../../../../injection_container.dart';
import '../../../auth/auth_injection.dart';
import '../../../auth/presentation/controller/resolve_visitor_state/resolve_visitor_state_cubit.dart';
import '../pages/splash_screen.dart';

part 'router.g.dart';

const String _splashScopeName = 'SplashScope';

@TypedGoRoute<SplashRoute>(path: AppRoutes.splash, name: AppRoutes.splash)
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute({this.sessionExpired = false});

  final bool sessionExpired;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return FeatureScope(
      scopeName: _splashScopeName,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerVisitorState,
      ],
      child: MultiBlocProvider(
        providers: <BlocProvider<dynamic>>[
          BlocProvider<ResolveVisitorStateCubit>(
            create: (_) => ServiceLocator.instance<ResolveVisitorStateCubit>(),
          ),
        ],
        child: SplashScreen(sessionExpired: sessionExpired),
      ),
    );
  }
}

extension SplashNavigation on BuildContext {
  void goSplash() => const SplashRoute().go(this);

  void pushSplash() => const SplashRoute().push(this);
}
