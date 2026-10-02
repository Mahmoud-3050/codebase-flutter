import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:codebase/injection_container.dart';

import '../../test/features/auth/fixtures.dart';
import '../router_harness.dart';

/// Integration test: Password recovery journey.
///
/// Verifies FR-046:
/// 1. Opens forgot password screen
/// 2. User enters registered email and submits request
/// 3. API returns OTP challenge for password reset
/// 4. App navigates to ResetPasswordScreen with email args
///
/// FR-046
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage(
      dioConsumer: FakeDioConsumer(
        postHandler: (String path, dynamic body) async {
          return kOtpChallengeJson(purpose: 'password_reset', resend: 60);
        },
      ),
    );
  });

  tearDown(() => ServiceLocator.instance.reset());

  testWidgets('FR-046 forgot password requests reset OTP and navigates to reset password screen', (
    WidgetTester tester,
  ) async {
    final GetIt sl = ServiceLocator.instance;
    sl<VisitorRedirect>().publish(UserType.firstOpen);

    await IntegrationRouterHarness.pump(
      tester,
      initialLocation: AppRoutes.forgotPassword,
    );
    await tester.pumpAndSettle();

    expect(find.text(Strings.forgotPassword), findsWidgets);
    expect(find.text(Strings.email), findsWidgets);

    // Enter email
    await tester.enterText(find.byType(TextField).first, 'ada@example.com');
    await tester.pump();

    // Tap Send button
    await tester.tap(find.widgetWithText(ElevatedButton, Strings.send).first);
    await tester.pumpAndSettle();

    // Verify cross-screen navigation reached ResetPasswordScreen
    expect(find.byType(ResetPasswordScreen), findsOneWidget);
    expect(find.text(Strings.resetPassword), findsWidgets);
  });
}
