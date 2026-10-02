import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/presentation/pages/login_screen.dart';
import 'package:codebase/features/auth/presentation/pages/register_screen.dart';
import 'package:codebase/injection_container.dart';

import '../router_harness.dart';

/// Integration test: Welcome screen options and cross-screen navigation.
///
/// Verifies FR-001, FR-030, FR-035:
/// 1. Welcome screen offers Google Sign-In, Email Sign-In, Register, and Guest
/// 2. Google sign-in button is accessible with proper state
/// 3. Navigating to Register from Welcome mounts RegisterScreen
/// 4. Navigating to Login from Welcome mounts LoginScreen
///
/// FR-001 FR-030 FR-035
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage();
  });

  tearDown(() => ServiceLocator.instance.reset());

  testWidgets('FR-001 FR-030 welcome renders Google button and navigates to login/register', (
    WidgetTester tester,
  ) async {
    final GetIt sl = ServiceLocator.instance;
    sl<VisitorRedirect>().publish(UserType.firstOpen);

    await IntegrationRouterHarness.pump(
      tester,
      initialLocation: AppRoutes.welcome,
    );
    await tester.pumpAndSettle();

    // Verify all primary entry points exist on Welcome screen
    expect(find.text(Strings.signInWithGoogle), findsOneWidget);
    expect(find.text(Strings.signInWithEmail), findsOneWidget);
    expect(find.text(Strings.register), findsWidgets);
    expect(find.text(Strings.continueAsGuest), findsOneWidget);

    // Tap "Sign In with Email" and verify cross-screen navigation
    await tester.tap(find.text(Strings.signInWithEmail));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    // Navigate back to welcome and tap "Register"
    final router = await IntegrationRouterHarness.pump(
      tester,
      initialLocation: AppRoutes.welcome,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.register).first);
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
