import 'package:either/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/domain/entities/register_response.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/domain/entities/verify_email_response.dart';
import 'package:codebase/features/auth/domain/usecases/register_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_email_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_email_usecase.dart';

import '../../dummy_eithers.dart';
import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test('FR-008 RegisterParams.toJson uses wire names and omits avatarPath', () {
    const RegisterParams params = RegisterParams(
      fullName: 'Ada',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
      password: 'secret12',
      avatarPath: '/tmp/a.png',
    );
    expect(params.toJson(), <String, dynamic>{
      'full_name': 'Ada',
      'email': 'ada@example.com',
      'dialing_code': '+966',
      'phone': '500000000',
      'password': 'secret12',
    });
    expect(params.toJson().containsKey('avatarPath'), isFalse);
    expect(params.toJson().containsKey('avatar'), isFalse);
  });

  test('FR-008 RegisterUseCase delegates to repository', () async {
    final MockAuthRepository repository = MockAuthRepository();
    const RegisterResponse response = RegisterResponse(
      status: 'success',
      message: 'ok',
      data: kEmailChallenge,
    );
    when(
      repository.register(params: anyNamed('params')),
    ).thenAnswer((_) async => const Right<Failure, RegisterResponse>(response));
    final RegisterUseCase useCase = RegisterUseCase(repository: repository);
    final Either<Failure, RegisterResponse> result = await useCase(
      const RegisterParams(
        fullName: 'Ada',
        email: 'ada@example.com',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret12',
      ),
    );
    expect(result.isRight, isTrue);
  });

  test(
    'FR-011 VerifyEmailUseCase and RequestEmailOtpUseCase pass through',
    () async {
      final MockAuthRepository repository = MockAuthRepository();
      when(repository.verifyEmail(params: anyNamed('params'))).thenAnswer(
        (_) async => Right<Failure, VerifyEmailResponse>(
          VerifyEmailResponse(status: 'success', message: 'ok', data: kSession),
        ),
      );
      when(repository.requestEmailOtp(params: anyNamed('params'))).thenAnswer(
        (_) async => const Right<Failure, RequestOtpResponse>(
          RequestOtpResponse(
            status: 'success',
            message: 'ok',
            data: kEmailChallenge,
          ),
        ),
      );
      expect(
        (await VerifyEmailUseCase(repository: repository)(
          const VerifyEmailParams(email: 'a@b.c', code: kValidOtpCode),
        )).isRight,
        isTrue,
      );
      expect(
        (await RequestEmailOtpUseCase(repository: repository)(
          const RequestEmailOtpParams(email: 'a@b.c'),
        )).isRight,
        isTrue,
      );
    },
  );
}
