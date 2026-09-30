import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_util/screen_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:themes/testing.dart';
import 'package:themes/themes.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/config/themes/app_theme.dart';
import 'package:codebase/config/themes/colors_palettes.dart';
import 'package:codebase/core/services/local_storage/impl/access_token_storage.dart';
import 'package:codebase/core/services/local_storage/impl/user_type_storage.dart';
import 'package:codebase/features/auth/presentation/navigation/router.dart'
    as auth;
import 'package:codebase/features/auth/presentation/pages/complete_registration_screen.dart';
import 'package:codebase/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:codebase/features/auth/presentation/pages/login_screen.dart';
import 'package:codebase/features/auth/presentation/pages/phone_otp_screen.dart';
import 'package:codebase/features/auth/presentation/pages/phone_sign_in_screen.dart';
import 'package:codebase/features/auth/presentation/pages/register_screen.dart';
import 'package:codebase/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:codebase/features/auth/presentation/pages/verify_email_screen.dart';
import 'package:codebase/features/auth/presentation/pages/welcome_screen.dart';
import 'package:codebase/features/home/presentation/navigation/router.dart'
    as home;
import 'package:codebase/features/home/presentation/pages/home_screen.dart';
import 'package:codebase/injection_container.dart';

import '../../fixtures.dart';

Future<void> _registerStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  FlutterSecureStorage.setMockInitialValues(<String, String>{});
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
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required String location,
  Object? extra,
}) async {
  await Themes.instance.init(config: ColorsPalettes.config);
  tester.view.physicalSize = const Size(1179, 2556);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  final GoRouter router = GoRouter(
    initialLocation: location,
    initialExtra: extra,
    routes: <RouteBase>[...auth.$appRoutes, ...home.$appRoutes],
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
  await tester.pump(const Duration(milliseconds: 50));
  return router;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(_registerStorage);
  tearDown(() async {
    resetThemes();
    await ServiceLocator.instance.reset();
  });

  testWidgets('FR-001 FeatureScope routes build welcome and login', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpRouter(
      tester,
      location: AppRoutes.welcome,
    );
    expect(find.byType(WelcomeScreen), findsOneWidget);
    router.go(AppRoutes.login);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('FR-005 FR-014 FeatureScope routes build register and recovery', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpRouter(
      tester,
      location: AppRoutes.register,
    );
    expect(find.byType(RegisterScreen), findsOneWidget);
    router.go(AppRoutes.forgotPassword);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    router.go(
      Uri(
        path: AppRoutes.resetPassword,
        queryParameters: <String, String>{'email': 'ada@example.com'},
      ).toString(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
  });

  testWidgets('FR-011 FR-019 FeatureScope routes build OTP screens', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpRouter(
      tester,
      location: Uri(
        path: AppRoutes.verifyEmail,
        queryParameters: <String, String>{
          'email': 'ada@example.com',
          'resend-available-in-seconds': '12',
        },
      ).toString(),
    );
    expect(find.byType(VerifyEmailScreen), findsOneWidget);
    router.go(AppRoutes.phoneSignIn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PhoneSignInScreen), findsOneWidget);
    router.go(
      Uri(
        path: AppRoutes.phoneOtp,
        queryParameters: <String, String>{
          'dialing-code': '+966',
          'phone': '500000000',
          'resend-available-in-seconds': '8',
          'purpose': 'verify_phone',
        },
      ).toString(),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(PhoneOtpScreen), findsOneWidget);
  });

  testWidgets('FR-022 FR-003 complete-registration and home scopes', (
    WidgetTester tester,
  ) async {
    final GoRouter router = await _pumpRouter(
      tester,
      location: AppRoutes.completeRegistration,
      extra: kPhoneDraft,
    );
    expect(find.byType(CompleteRegistrationScreen), findsOneWidget);
    expect(find.text(Strings.completeRegistration), findsWidgets);
    router.go('${AppRoutes.home}?session-expired=true');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
