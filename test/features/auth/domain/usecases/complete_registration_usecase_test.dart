import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/features/auth/domain/enums/registration_source.dart';
import 'package:codebase/features/auth/domain/usecases/complete_registration_usecase.dart';

void main() {
  test(
    'FR-025 CompleteRegistrationParams.toJson omits avatarPath and nulls',
    () {
      const CompleteRegistrationParams params = CompleteRegistrationParams(
        registrationToken: 'tok',
        source: RegistrationSource.google,
        fullName: 'Ada',
        password: 'secret12',
        avatarPath: '/tmp/a.png',
      );
      expect(params.toJson(), <String, dynamic>{
        'registration_token': 'tok',
        'full_name': 'Ada',
        'password': 'secret12',
      });
      expect(params.toJson().containsKey('avatarPath'), isFalse);
    },
  );
}
