import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart' hide DeviceType;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/config/routes/visitor_redirect.dart';
import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/core/api/dio_consumer.dart';
import 'package:codebase/core/di/auth_data_scope_lease.dart';
import 'package:codebase/core/services/local_storage/impl/access_token_storage.dart';
import 'package:codebase/core/services/local_storage/impl/device_token_storage.dart';
import 'package:codebase/core/services/local_storage/impl/user_type_storage.dart';
import 'package:codebase/core/services/session_write_guard.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/presentation/navigation/router.dart'
    as auth;
import 'package:codebase/features/home/presentation/navigation/router.dart'
    as home;
import 'package:codebase/features/splash/presentation/navigation/router.dart'
    as splash;
import 'package:codebase/injection_container.dart';

/// Test double for [DioConsumer] that responds with empty JSON or custom handler.
class FakeDioConsumer implements DioConsumer {
  FakeDioConsumer({this.postHandler, this.getHandler});

  final Future<dynamic> Function(String path, dynamic body)? postHandler;
  final Future<dynamic> Function(String path, dynamic queryParameters)?
  getHandler;

  @override
  Future<dynamic> delete(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return <String, dynamic>{'status': true, 'data': <String, dynamic>{}};
  }

  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
    CancelToken? cancelToken,
  }) async {
    if (getHandler != null) {
      return getHandler!(path, queryParameters);
    }
    return <String, dynamic>{'status': true, 'data': <String, dynamic>{}};
  }

  @override
  Future<dynamic> patch(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return <String, dynamic>{'status': true, 'data': <String, dynamic>{}};
  }

  @override
  Future<dynamic> post(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    if (postHandler != null) {
      return postHandler!(path, body);
    }
    return <String, dynamic>{'status': true, 'data': <String, dynamic>{}};
  }

  @override
  Future<dynamic> put(
    String path, {
    FormData? formData,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    return <String, dynamic>{'status': true, 'data': <String, dynamic>{}};
  }
}

/// Router harness for real GoRouter integration tests.
class IntegrationRouterHarness {
  static Future<void> registerStorage({DioConsumer? dioConsumer}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final GetIt sl = ServiceLocator.instance;
    await sl.reset();
    sl.allowReassignment = true;

    sl.registerLazySingleton<SharedPreferences>(
      () => prefs,
      instanceName: 'sharedPreferences',
    );
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
      instanceName: 'secureStorage',
    );
    sl.registerLazySingleton<UserTypeStorage>(
      () => UserTypeStorage(preferences: prefs),
    );
    sl.registerLazySingleton<AccessTokenStorage>(
      () => AccessTokenStorage(
        secureStorage: sl<FlutterSecureStorage>(instanceName: 'secureStorage'),
      ),
    );
    sl.registerLazySingleton<DeviceTokenStorage>(
      () => DeviceTokenStorage(
        secureStorage: sl<FlutterSecureStorage>(instanceName: 'secureStorage'),
      ),
    );
    sl.registerLazySingleton<AuthDataScopeLease>(() => AuthDataScopeLease(sl));
    sl.registerLazySingleton<VisitorRedirect>(VisitorRedirect.new);
    sl.registerLazySingleton<SessionWriteGuard>(CountingSessionWriteGuard.new);
    sl.registerLazySingleton<DioConsumer>(
      () => dioConsumer ?? FakeDioConsumer(),
    );
    sl.registerLazySingleton<DeviceType>(
      () => DeviceType.android,
      instanceName: 'deviceType',
    );
    sl.registerLazySingleton<String>(
      () => 'test-device-id',
      instanceName: 'deviceId',
    );
  }

  static Future<GoRouter> pump(
    WidgetTester tester, {
    String initialLocation = AppRoutes.splash,
    Object? initialExtra,
  }) async {
    await Themes.instance.init(config: ColorsPalettes.config);
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(resetThemes);

    final VisitorRedirect visitorRedirect =
        ServiceLocator.instance<VisitorRedirect>();

    final GoRouter router = GoRouter(
      initialLocation: initialLocation,
      initialExtra: initialExtra,
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
      ],
    );

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (BuildContext context, Widget? _) {
          return MaterialApp.router(
            theme: appTheme(ColorsPalettes.config.light, Brightness.light),
            routerConfig: router,
          );
        },
      ),
    );
    await tester.pump();
    return router;
  }
}
