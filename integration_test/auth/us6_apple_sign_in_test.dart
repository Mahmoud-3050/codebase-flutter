import 'package:codebase/config/routes/visitor_redirect.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/injection_container.dart';

import '../router_harness.dart';

/// Integration test: Apple sign-in platform availability.
///
/// Verifies FR-029, FR-034a:
/// 1. Apple button is hidden on Android
/// 2. Apple button is rendered and available on iOS
///
/// FR-029 FR-034a
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    FlutterSecureStorage.setMockInitialValues(<String, String>{});
    await IntegrationRouterHarness.registerStorage();
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    return ServiceLocator.instance.reset();
  });

  testWidgets(
    'FR-029 FR-034a Apple button visibility is platform-aware on welcome screen',
    (WidgetTester tester) async {
      final GetIt sl = ServiceLocator.instance;
      sl<VisitorRedirect>().publish(UserType.firstOpen);

      // 1. On Android: Apple sign-in must be hidden
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      await IntegrationRouterHarness.pump(
        tester,
        initialLocation: AppRoutes.welcome,
      );
      await tester.pumpAndSettle();
      expect(find.text(Strings.signInWithApple), findsNothing);

      // 2. On iOS: Apple sign-in must be displayed
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      await IntegrationRouterHarness.pump(
        tester,
        initialLocation: AppRoutes.welcome,
      );
      await tester.pumpAndSettle();
      expect(find.text(Strings.signInWithApple), findsOneWidget);
    },
  );
}
