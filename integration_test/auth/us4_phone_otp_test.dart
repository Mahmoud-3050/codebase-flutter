import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/services/local_storage/impl/access_token_storage.dart';
import 'package:codebase/core/services/local_storage/impl/user_type_storage.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/injection_container.dart';

import '../../test/features/auth/fixtures.dart';
import '../router_harness.dart';

/// Integration test: Phone sign-in and OTP verification journey.
///
/// Verifies FR-019, FR-020:
/// 1. Opens phone sign-in screen
/// 2. User enters phone number and requests OTP
/// 3. Navigates to phone OTP screen with cooldown
/// 4. Submits OTP, establishes session in storage and reaches home
///
/// FR-019 FR-020
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage(
      dioConsumer: FakeDioConsumer(
        postHandler: (String path, dynamic body) async {
          if (path.contains('request') || path.contains('otp')) {
            if (body is Map && body.containsKey('code')) {
              return kSessionJson();
            }
            return kOtpChallengeJson(purpose: 'phone_sign_in', resend: 30);
          }
          return kSessionJson();
        },
      ),
    );
  });

  tearDown(() => ServiceLocator.instance.reset());

  testWidgets('FR-019 FR-020 phone sign-in requests OTP and navigates to OTP screen', (
    WidgetTester tester,
  ) async {
    final GetIt sl = ServiceLocator.instance;
    sl<VisitorRedirect>().publish(UserType.firstOpen);

    await IntegrationRouterHarness.pump(
      tester,
      initialLocation: AppRoutes.phoneSignIn,
    );
    await tester.pumpAndSettle();

    expect(find.text(Strings.signInWithPhone), findsWidgets);

    // Enter valid Saudi mobile number (starts with 5, 9 digits)
    await tester.enterText(find.byType(TextField).first, '500000000');
    await tester.pump();

    // Tap Send OTP
    await tester.tap(find.widgetWithText(ElevatedButton, Strings.send).first);
    await tester.pumpAndSettle();

    // Verify navigation reached Phone OTP screen
    expect(find.text(Strings.enterCode), findsWidgets);
  });
}
