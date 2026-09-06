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
      expect(content, contains('LoginScreen(token: token)'));
      expect(content, isNot(contains('FeatureScope')));
    });

    test('should handle empty args without a feature scope', () {
      final content = FeatureRouterHandler.buildRouteClass(
        'HomeRoute',
        'HomeScreen',
        'home',
        {},
      );
      expect(content, contains('const HomeRoute();'));
      expect(content, contains('const HomeScreen()'));
      expect(content, isNot(contains('FeatureScope')));
    });

    test('should wrap scoped routes in FeatureScope and BlocProviders', () {
      final content = FeatureRouterHandler.buildRouteClass(
        'StudentProfileRoute',
        'StudentProfileScreen',
        'studentProfile',
        {},
        feature: 'profile',
        scopes: const ['getStudentProfile', 'updateStudentProfile'],
      );

      expect(content, contains('return FeatureScope('));
      expect(content, contains('scopeName: _studentProfileScopeName'));
      expect(content, contains('registerProfileDataLayer'));
      expect(content, contains('registerGetStudentProfile'));
      expect(content, contains('registerUpdateStudentProfile'));
      expect(content, contains('MultiBlocProvider('));
      expect(
        content,
        contains('ServiceLocator.instance<GetStudentProfileCubit>()'),
      );
      expect(
        content,
        contains('ServiceLocator.instance<UpdateStudentProfileCubit>()'),
      );
      expect(content, contains('child: const StudentProfileScreen()'));
    });
  });

  group('FeatureRouterHandler.buildNavigationMethod', () {
    test('should generate go and typed push variants with args', () {
      final content = FeatureRouterHandler.buildNavigationMethod(
        'DetailsRoute',
        'DetailsScreen',
        {'id': 1},
      );

      expect(content, contains('void goDetails({'));
      expect(content, contains('Future<T?> pushDetails<T>({'));
      expect(content, contains('required int id'));
      expect(content, contains(').go(this)'));
      expect(content, contains(').push<T>(this)'));
    });

    test('should generate simple methods for no args', () {
      final content = FeatureRouterHandler.buildNavigationMethod(
        'SettingsRoute',
        'SettingsScreen',
        {},
      );

      expect(
        content,
        contains('void goSettings() => const SettingsRoute().go(this);'),
      );
      expect(
        content,
        contains(
          'Future<T?> pushSettings<T>() => const SettingsRoute().push<T>(this);',
        ),
      );
    });
  });

  group('FeatureRouterHandler naming helpers', () {
    test('should emit a private per-screen scope constant', () {
      expect(
        FeatureRouterHandler.scopeConstantDeclaration('StudentProfileScreen'),
        "const String _studentProfileScopeName = 'StudentProfileScope';",
      );
    });

    test('should always prepend the feature data-layer registration', () {
      expect(
        FeatureRouterHandler.registrationNames('profile', [
          'getStudentProfile',
          'updateStudentProfile',
        ]),
        [
          'registerProfileDataLayer',
          'registerGetStudentProfile',
          'registerUpdateStudentProfile',
        ],
      );
    });

    test('should emit a per-screen navigation extension', () {
      final content = FeatureRouterHandler.buildNavigationExtension(
        'StudentProfileRoute',
        'StudentProfileScreen',
        {},
      );
      expect(
        content,
        contains('extension StudentProfileNavigation on BuildContext'),
      );
      expect(content, contains('void goStudentProfile()'));
      expect(content, contains('Future<T?> pushStudentProfile<T>()'));
    });
  });
}
