import 'package:flutter_test/flutter_test.dart';
import '../src/router_utils.dart';

void main() {
  group('RouterUtils.findBlockEnd', () {
    test('should find the end of a simple block', () {
      const content = 'class Test { void main() {} }';
      final end = RouterUtils.findBlockEnd(content, 0);
      expect(end, content.length);
    });

    test('should handle nested braces', () {
      const content =
          'class Test { void main() { if(true) { print("hi"); } } }';
      final end = RouterUtils.findBlockEnd(content, 0);
      expect(end, content.length);
    });

    test('should return -1 if no brace found', () {
      const content = 'class Test';
      final end = RouterUtils.findBlockEnd(content, 0);
      expect(end, -1);
    });
  });

  group('RouterUtils.removeBlock', () {
    test('should remove a class block and its annotation', () {
      const content = '''
import 'package:flutter/material.dart';

@TypedGoRoute<OldRoute>(path: '/old')
class OldRoute extends GoRouteData {
  Widget build() => Container();
}

class NewRoute {}
''';
      final result = RouterUtils.removeBlock(content, 'class OldRoute');
      expect(result.contains('class OldRoute'), isFalse);
      expect(result.contains('@TypedGoRoute<OldRoute>'), isFalse);
      expect(result.contains('class NewRoute'), isTrue);
    });

    test('should return same content if pattern not found', () {
      const content = 'class Test {}';
      final result = RouterUtils.removeBlock(content, 'class NonExistent');
      expect(result, content);
    });

    test(
      'should remove a scoped route without touching the next extension',
      () {
        const content = '''
part 'router.g.dart';

const String _studentProfileScopeName = 'StudentProfileScope';

@TypedGoRoute<StudentProfileRoute>(
  path: AppRoutes.studentProfile,
  name: AppRoutes.studentProfile,
)
class StudentProfileRoute extends GoRouteData {
  Widget build() {
    return FeatureScope(
      child: MultiBlocProvider(
        providers: [],
        child: const StudentProfileScreen(),
      ),
    );
  }
}

extension StudentProfileNavigation on BuildContext {
  void goStudentProfile() => const StudentProfileRoute().go(this);
}
''';
        final result = RouterUtils.removeBlock(
          content,
          'class StudentProfileRoute',
        );
        expect(result.contains('class StudentProfileRoute'), isFalse);
        expect(result.contains('@TypedGoRoute<StudentProfileRoute>'), isFalse);
        expect(result.contains('_studentProfileScopeName'), isFalse);
        expect(result.contains('extension StudentProfileNavigation'), isTrue);
      },
    );
  });

  group('RouterUtils.scopesMatch', () {
    test('should match when FeatureScope registrations are exact', () {
      const content = '''
class StudentProfileRoute extends GoRouteData {
  Widget build() {
    return FeatureScope(
      registrations: const [
        registerProfileDataLayer,
        registerGetStudentProfile,
      ],
      child: const StudentProfileScreen(),
    );
  }
}
''';
      expect(
        RouterUtils.scopesMatch(content, 'StudentProfileRoute', [
          'registerProfileDataLayer',
          'registerGetStudentProfile',
        ]),
        isTrue,
      );
    });

    test('should reject unscoped routes when scopes are expected', () {
      const content = '''
class SplashRoute extends GoRouteData {
  Widget build() => const SplashScreen();
}
''';
      expect(
        RouterUtils.scopesMatch(content, 'SplashRoute', [
          'registerSplashDataLayer',
        ]),
        isFalse,
      );
      expect(RouterUtils.scopesMatch(content, 'SplashRoute', []), isTrue);
    });
  });

  group('RouterUtils.argsMatch', () {
    test('should return true if args match class fields exactly', () {
      const content = '''
class LoginRoute extends GoRouteData {
  final String email;
  final int attempts;
  const LoginRoute({required this.email, required this.attempts});
}
''';
      final args = {'email': 'test@test.com', 'attempts': 5};
      expect(RouterUtils.argsMatch(content, 'LoginRoute', args), isTrue);
    });

    test('should return false if field count differs', () {
      const content = '''
class LoginRoute extends GoRouteData {
  final String email;
  const LoginRoute({required this.email});
}
''';
      final args = {'email': 'test@test.com', 'attempts': 5};
      expect(RouterUtils.argsMatch(content, 'LoginRoute', args), isFalse);
    });

    test('should return true for empty args and no fields', () {
      const content = '''
class HomeRoute extends GoRouteData {
  const HomeRoute();
}
''';
      expect(RouterUtils.argsMatch(content, 'HomeRoute', {}), isTrue);
    });
  });
}
