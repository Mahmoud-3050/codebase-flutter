import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/services/local_storage/impl/access_token_storage.dart';
import 'package:codebase/core/services/local_storage/impl/user_type_storage.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/injection_container.dart';

import '../router_harness.dart';

/// Integration test: cold-start as a first-time visitor.
///
/// Verifies that [VisitorRedirect] routes the initial cold start across
/// first-open, guest, returning-loggedIn, and corrupted-state scenarios
/// using real storage and real GoRouter navigation.
///
/// FR-001 FR-014 FR-038 SC-002 SC-003
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage();
  });

  tearDown(() => ServiceLocator.instance.reset());

  testWidgets('FR-001 first-open routes to welcome screen', (
    WidgetTester tester,
  ) async {
    // No token, no user-type stored → firstOpen visitor state
    await IntegrationRouterHarness.pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(Strings.continueAsGuest), findsOneWidget);
  });

  testWidgets('FR-038 guest visitor state routes to home screen on relaunch', (
    WidgetTester tester,
  ) async {
    // Set user-type to guest in SharedPreferences
    final GetIt sl = ServiceLocator.instance;
    await sl<UserTypeStorage>().save(value: UserType.guest.name);

    await IntegrationRouterHarness.pump(tester);
    await tester.pumpAndSettle();

    // Guest relaunches straight into home per FR-038
    expect(find.text(Strings.home), findsOneWidget);
  });

  testWidgets('FR-014 returning loggedIn user bypasses welcome to home', (
    WidgetTester tester,
  ) async {
    // Seed a valid session token and loggedIn user-type
    final GetIt sl = ServiceLocator.instance;
    await sl<AccessTokenStorage>().save(value: 'valid-token-abc');
    await sl<UserTypeStorage>().save(value: UserType.loggedIn.name);

    await IntegrationRouterHarness.pump(tester);
    await tester.pumpAndSettle();

    // Should arrive at home, not welcome
    expect(find.text(Strings.continueAsGuest), findsNothing);
    expect(find.text(Strings.home), findsOneWidget);
  });

  testWidgets('SC-002 loggedIn token + missing user-type falls back to welcome', (
    WidgetTester tester,
  ) async {
    // Edge case: token exists but user-type was never persisted (corrupted state).
    // readVisitorState() falls back to firstOpen when user-type is blank.
    final GetIt sl = ServiceLocator.instance;
    await sl<AccessTokenStorage>().save(value: 'token-no-type');

    await IntegrationRouterHarness.pump(tester);
    await tester.pumpAndSettle();

    expect(find.text(Strings.continueAsGuest), findsOneWidget);
  });
}
