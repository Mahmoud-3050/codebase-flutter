import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/domain/usecases/reset_password_usecase.dart';

void main() {
  test('FR-046c ResetPasswordParams.toJson includes confirmation', () {
    expect(
      const ResetPasswordParams(
        email: 'ada@example.com',
        code: '123456',
        password: 'secret12',
      ).toJson(),
      <String, dynamic>{
        'email': 'ada@example.com',
        'code': '123456',
        'password': 'secret12',
        'password_confirmation': 'secret12',
      },
    );
  });
}
