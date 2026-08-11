import 'package:flutter_test/flutter_test.dart';
import '../src/feature_router_handler.dart';

void main() {
  group('FeatureRouterHandler.buildRouteClass', () {
    test('should generate a typed route class with named route support', () {
      final content = FeatureRouterHandler.buildRouteClass(
        'LoginRoute',
        'LoginScreen',
        'login',
        {'token': 'abc'},
      );

      expect(content, contains('@TypedGoRoute<LoginRoute>'));
      expect(content, contains('path: AppRoutes.login'));
      expect(content, contains('name: AppRoutes.login'));
      expect(content, contains('class LoginRoute extends GoRouteData'));
      expect(content, contains('final String token;'));
      expect(
          content,
          contains(
              'Widget build(BuildContext context, GoRouterState state) => LoginScreen(token: token);'));
    });

    test('should handle empty args', () {
      final content = FeatureRouterHandler.buildRouteClass(
        'HomeRoute',
        'HomeScreen',
        'home',
        {},
      );
      expect(content, contains('const HomeRoute();'));
      expect(content, contains('=> const HomeScreen();'));
    });
  });

  group('FeatureRouterHandler.buildNavigationMethod', () {
    test('should generate go and push variants with args', () {
      final content = FeatureRouterHandler.buildNavigationMethod(
        'DetailsRoute',
        'DetailsScreen',
        {'id': 1},
      );

      expect(content, contains('void goDetails({'));
      expect(content, contains('void pushDetails({'));
      expect(content, contains('required int id'));
      expect(content, contains(').go(this)'));
      expect(content, contains(').push(this)'));
    });

    test('should generate simple methods for no args', () {
      final content = FeatureRouterHandler.buildNavigationMethod(
        'SettingsRoute',
        'SettingsScreen',
        {},
      );

      expect(content,
          contains('void goSettings() => const SettingsRoute().go(this);'));
      expect(content,
          contains('void pushSettings() => const SettingsRoute().push(this);'));
    });
  });
}
