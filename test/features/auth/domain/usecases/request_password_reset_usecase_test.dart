import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/domain/usecases/request_password_reset_usecase.dart';

void main() {
  test('FR-046 RequestPasswordResetParams.toJson', () {
    expect(
      const RequestPasswordResetParams(email: 'ada@example.com').toJson(),
      <String, dynamic>{'email': 'ada@example.com'},
    );
  });
}
