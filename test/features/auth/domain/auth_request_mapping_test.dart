import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service.dart';
import 'package:codebase/features/auth/domain/entities/login_outcome.dart';
import 'package:codebase/features/auth/domain/entities/login_response.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';
import 'package:codebase/features/auth/domain/enums/social_provider.dart';
import 'package:codebase/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/register_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_email_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_phone_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/social_sign_in_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/resolve_visitor_state_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_phone_otp_usecase.dart';

import '../dummy_eithers.dart';
import '../fixtures.dart';
import '../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test('auth request params map to JSON', () {
    expect(
      const LoginParams(email: 'a@b.c', password: 'secret').toJson(),
      containsPair('email', 'a@b.c'),
    );
    expect(
      const RegisterParams(
        fullName: 'Ada',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret',
      ).toJson(),
      containsPair('full_name', 'Ada'),
    );
    expect(
      const RequestEmailOtpParams(email: 'a@b.c').toJson(),
      containsPair('email', 'a@b.c'),
    );
    expect(
      const RequestPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
      ).toJson(),
      containsPair('phone', '500000000'),
    );
    expect(
      const VerifyEmailParams(email: 'a@b.c', code: '1234').toJson(),
      containsPair('code', '1234'),
    );
    expect(
      const VerifyPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        code: '1234',
        purpose: OtpPurpose.phoneSignIn,
      ).toJson(),
      containsPair('code', '1234'),
    );
    expect(
      const RequestPasswordResetParams(email: 'a@b.c').toJson(),
      containsPair('email', 'a@b.c'),
    );
    expect(
      const ResetPasswordParams(
        email: 'a@b.c',
        code: '1234',
        password: 'secret',
        passwordConfirmation: 'secret',
      ).toJson(),
      containsPair('password_confirmation', 'secret'),
    );
    expect(
      const SocialSignInParams(provider: SocialProvider.google).toJson(),
      containsPair('provider', 'google'),
    );
    expect(
      const CompleteRegistrationParams(
        registrationToken: 'token',
        source: RegistrationSource.phone,
        fullName: 'Ada',
        password: 'secret',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        avatarPath: 'avatar.png',
      ).toJson(),
      containsPair('email', 'a@b.c'),
    );
    expect(
      LoginParams(email: 'a@b.c', password: 'secret'),
      LoginParams(email: 'a@b.c', password: 'secret'),
    );
    expect(
      RegisterParams(
        fullName: 'Ada',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret',
      ),
      RegisterParams(
        fullName: 'Ada',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret',
      ),
    );
    expect(
      ResetPasswordParams(
        email: 'a@b.c',
        code: '1234',
        password: 'secret',
        passwordConfirmation: 'secret',
      ),
      ResetPasswordParams(
        email: 'a@b.c',
        code: '1234',
        password: 'secret',
        passwordConfirmation: 'secret',
      ),
    );
    expect(
      VerifyPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        code: '1234',
        purpose: OtpPurpose.phoneSignIn,
      ),
      VerifyPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        code: '1234',
        purpose: OtpPurpose.phoneSignIn,
      ),
    );
    expect(
      RequestPhoneOtpParams(dialingCode: '+966', phone: '500000000'),
      RequestPhoneOtpParams(dialingCode: '+966', phone: '500000000'),
    );
    expect(
      SocialSignInParams(provider: SocialProvider.google, idToken: 'id'),
      SocialSignInParams(provider: SocialProvider.google, idToken: 'id'),
    );
    expect(
      CompleteRegistrationParams(
        registrationToken: 'token',
        source: RegistrationSource.phone,
        fullName: 'Ada',
        password: 'secret',
      ),
      CompleteRegistrationParams(
        registrationToken: 'token',
        source: RegistrationSource.phone,
        fullName: 'Ada',
        password: 'secret',
      ),
    );
    expect(SocialProvider.fromWireName('apple'), SocialProvider.apple);
    expect(() => SocialProvider.fromWireName('unknown'), throwsFormatException);
    expect(
      LoginResponse(
        status: 'success',
        message: '',
        data: LoginSucceeded(kSession),
      ).props,
      isNotEmpty,
    );
    expect(
      const SocialCredential(
        provider: SocialProvider.google,
        idToken: 'id',
      ).props,
      contains(SocialProvider.google),
    );
  });

  test('FR-002 resolve visitor state delegates', () async {
    final MockAuthRepository repository = MockAuthRepository();
    when(
      repository.resolveVisitorState(params: anyNamed('params')),
    ).thenAnswer((_) async => const Right<Failure, UserType>(UserType.guest));
    expect(
      (await ResolveVisitorStateUseCase(repository: repository)(
        const NoParams(),
      )).isRight,
      isTrue,
    );
  });
}
