import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/config/routes/app_routes.dart';
import 'package:codebase/config/routes/visitor_redirect.dart';
import 'package:codebase/core/utils/enums.dart';

void main() {
  test('FR-004 unknown visitor waits on splash and remembers home', () {
    String? remembered;
    expect(
      redirectForVisitor(
        type: null,
        path: AppRoutes.home,
        remember: (String location) => remembered = location,
      ),
      AppRoutes.splash,
    );
    expect(remembered, AppRoutes.home);
  });

  test('FR-004 splash stays put while visitor state is unknown', () {
    expect(
      redirectForVisitor(type: null, path: AppRoutes.splash, remember: (_) {}),
      isNull,
    );
  });

  test('FR-004 firstOpen cannot open home and is sent to welcome', () {
    String? remembered;
    expect(
      redirectForVisitor(
        type: UserType.firstOpen,
        path: AppRoutes.home,
        remember: (String location) => remembered = location,
      ),
      AppRoutes.welcome,
    );
    expect(remembered, AppRoutes.home);
  });

  test('FR-042 loggedIn home is not redirected', () {
    expect(
      redirectForVisitor(
        type: UserType.loggedIn,
        path: AppRoutes.home,
        remember: (_) => fail('should not remember'),
      ),
      isNull,
    );
  });

  test('FR-038 guest home is not redirected', () {
    expect(
      redirectForVisitor(
        type: UserType.guest,
        path: AppRoutes.home,
        remember: (_) => fail('should not remember'),
      ),
      isNull,
    );
  });
}
