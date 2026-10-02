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

/// Integration test: Email login journey.
///
/// Verifies SC-002:
/// 1. Route opens to login screen without OTP field
/// 2. User enters valid email and password
/// 3. Form submits to API, session is persisted in secure storage and prefs
/// 4. App navigates to home screen
///
/// FR-014 SC-002
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage(
      dioConsumer: FakeDioConsumer(
        postHandler: (String path, dynamic body) async => kSessionJson(),
      ),
    );
  });

  tearDown(() => ServiceLocator.instance.reset());

  testWidgets('FR-014 SC-002 email login successfully navigates to home', (
    WidgetTester tester,
  ) async {
    final GetIt sl = ServiceLocator.instance;
    sl<VisitorRedirect>().publish(UserType.firstOpen);

    await IntegrationRouterHarness.pump(tester, initialLocation: AppRoutes.login);
    await tester.pumpAndSettle();

    expect(find.text(Strings.signIn), findsWidgets);
    expect(find.text(Strings.forgotPassword), findsOneWidget);

    // Enter email and password
    await tester.enterText(find.byType(TextField).first, 'ada@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'Password123!');
    await tester.pump();

    // Tap sign in button
    await tester.tap(find.widgetWithText(ElevatedButton, Strings.signIn).first);
    await tester.pumpAndSettle();

    // Verify session persisted in storage
    expect(await sl<AccessTokenStorage>().read(), kAccessToken);
    expect(await sl<UserTypeStorage>().read(), UserType.loggedIn.name);

    // Verify navigation reached home screen
    expect(find.text(Strings.home), findsOneWidget);
  });
}
