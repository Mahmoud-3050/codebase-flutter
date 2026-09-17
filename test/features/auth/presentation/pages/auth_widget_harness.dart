import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';

Future<void> pumpAuthWidget(
  WidgetTester tester, {
  required Widget child,
  List<BlocProvider<dynamic>> providers = const <BlocProvider<dynamic>>[],
  List<RepositoryProvider<dynamic>> repositories =
      const <RepositoryProvider<dynamic>>[],
  TextDirection textDirection = TextDirection.ltr,
  TargetPlatform? platform,
}) async {
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
        AppRoutes.phoneOtp,
        AppRoutes.completeRegistration,
        AppRoutes.forgotPassword,
        AppRoutes.resetPassword,
      ])
        GoRoute(path: path, builder: (_, _) => Text('routed:$path')),
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
            return Directionality(
              textDirection: textDirection,
              child: widget ?? const SizedBox.shrink(),
            );
          },
        );
      },
    ),
  );
  await tester.pump();
}

Future<void> resetAuthWidget() async {
  resetThemes();
}
