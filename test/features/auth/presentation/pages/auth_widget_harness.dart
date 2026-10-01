import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/config/routes/visitor_redirect.dart';
import 'package:codebase/core/services/session_write_guard.dart';
import 'package:codebase/injection_container.dart';
import 'package:get_it/get_it.dart';
import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';

Future<void> pumpAuthWidget(
  WidgetTester tester, {
  required Widget child,
  List<BlocProvider<dynamic>> providers = const <BlocProvider<dynamic>>[],
  List<RepositoryProvider<dynamic>> repositories =
      const <RepositoryProvider<dynamic>>[],
  TextDirection textDirection = TextDirection.ltr,
  TextScaler? textScaler,
  TargetPlatform? platform,
  bool confirmPhoneOtp = false,
}) async {
  _ensureVisitorRedirect();
  await Themes.instance.init(config: ColorsPalettes.config);
  Widget body = child;
  if (providers.isNotEmpty) {
    body = MultiBlocProvider(providers: providers, child: body);
  }
  if (repositories.isNotEmpty) {
    body = MultiRepositoryProvider(providers: repositories, child: body);
  }
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(path: '/', builder: (_, _) => body),
      for (final String path in <String>[
        AppRoutes.home,
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.register,
        AppRoutes.verifyEmail,
        AppRoutes.phoneSignIn,
        AppRoutes.completeRegistration,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      ])
        GoRoute(path: path, builder: (_, _) => Text('routed:$path')),
      GoRoute(
        path: AppRoutes.phoneOtp,
        builder: (BuildContext context, _) {
          if (!confirmPhoneOtp) {
            return Text('routed:${AppRoutes.phoneOtp}');
          }
          return const _ConfirmPhoneOtpPage();
        },
      ),
    ],
  );
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(393, 852),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? _) {
        return MaterialApp.router(
          theme: appTheme(
            ColorsPalettes.config.light,
            Brightness.light,
          ).copyWith(platform: platform),
          routerConfig: router,
          builder: (BuildContext context, Widget? widget) {
            Widget child = Directionality(
              textDirection: textDirection,
              child: widget ?? const SizedBox.shrink(),
            );
            final TextScaler? scale = textScaler;
            if (scale != null) {
              child = MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scale),
                child: child,
              );
            }
            return child;
          },
        );
      },
    ),
  );
  await tester.pump();
}

void _ensureVisitorRedirect() {
  final GetIt sl = ServiceLocator.instance;
  if (!sl.isRegistered<VisitorRedirect>()) {
    sl.registerSingleton<VisitorRedirect>(VisitorRedirect());
  }
  if (!sl.isRegistered<SessionWriteGuard>()) {
    sl.registerSingleton<SessionWriteGuard>(CountingSessionWriteGuard());
  }
}

Future<void> resetAuthWidget() async {
  resetThemes();
}

class _ConfirmPhoneOtpPage extends StatefulWidget {
  const _ConfirmPhoneOtpPage();

  @override
  State<_ConfirmPhoneOtpPage> createState() => _ConfirmPhoneOtpPageState();
}

class _ConfirmPhoneOtpPageState extends State<_ConfirmPhoneOtpPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
