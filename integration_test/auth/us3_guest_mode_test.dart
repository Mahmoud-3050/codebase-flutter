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

import '../router_harness.dart';

/// Integration test: Guest mode journey.
///
/// Verifies SC-003, FR-037, FR-038, FR-039:
/// 1. Cold start to welcome screen offers "Continue as Guest"
/// 2. User taps "Continue as Guest"
/// 3. Guest state is persisted in storage and token is cleared
/// 4. App navigates to home screen
/// 5. Guest gate dialog is presented when a protected action is triggered
///
/// FR-037 FR-038 FR-039 SC-003
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage();
  });

  tearDown(() => ServiceLocator.instance.reset());

  testWidgets(
    'FR-037 FR-038 SC-003 guest tap persists guest state and reaches home',
    (WidgetTester tester) async {
      final GetIt sl = ServiceLocator.instance;

      await IntegrationRouterHarness.pump(
        tester,
        initialLocation: AppRoutes.welcome,
      );
      await tester.pumpAndSettle();

      expect(find.text(Strings.continueAsGuest), findsOneWidget);

      // Tap "Continue as Guest"
      await tester.tap(find.text(Strings.continueAsGuest));
      await tester.pumpAndSettle();

      // Verify guest state persisted in storage
      expect(await sl<UserTypeStorage>().read(), UserType.guest.name);
      expect(await sl<AccessTokenStorage>().read(), isNull);

      // Verify reached home screen
      expect(find.text(Strings.home), findsOneWidget);

      // Verify guest gate triggers on protected action (FR-039)
      await tester.tap(find.text(Strings.accountRequired));
      await tester.pumpAndSettle();

      // Guest gate dialog shows options
      expect(find.text(Strings.signIn), findsWidgets);
      expect(find.text(Strings.createAccount), findsWidgets);
    },
  );
}
