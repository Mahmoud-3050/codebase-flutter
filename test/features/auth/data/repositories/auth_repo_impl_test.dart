import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/data/models/login_model.dart';
import 'package:codebase/features/auth/data/models/register_model.dart';
import 'package:codebase/features/auth/data/models/request_otp_model.dart';
import 'package:codebase/features/auth/data/models/request_password_reset_model.dart';
import 'package:codebase/features/auth/data/models/reset_password_model.dart';
import 'package:codebase/features/auth/data/models/social_sign_in_model.dart';
import 'package:codebase/features/auth/data/models/verify_email_model.dart';
import 'package:codebase/features/auth/data/models/verify_phone_otp_model.dart';
import 'package:codebase/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:codebase/features/auth/data/models/logout_model.dart';
import 'package:codebase/features/auth/domain/enums/social_provider.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/register_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/social_sign_in_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service.dart';

import '../../dummy_eithers.dart';
import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  late MockAuthRemoteDataSource remote;
  late MockAuthLocalDataSource local;
  late MockSocialAuthService social;
  late AuthRepositoryImpl repository;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockAuthLocalDataSource();
    social = MockSocialAuthService();
    repository = AuthRepositoryImpl(
      remote: remote,
      local: local,
      socialAuthService: social,
    );
    when(local.persistSession(any)).thenAnswer((_) async {});
    when(local.saveRegistrationDraft(any)).thenAnswer((_) async {});
    when(local.clearRegistrationDraft()).thenAnswer((_) async {});
    when(local.clearSession()).thenAnswer((_) async {});
    when(local.markGuest()).thenAnswer((_) async {});
  });

  const RegisterParams registerParams = RegisterParams(
    fullName: 'Ada',
    email: 'ada@example.com',
    dialingCode: '+966',
    phone: '500000000',
    password: 'secret12',
  );

  test('FR-004 register never persists a session', () async {
    when(
      remote.register(params: anyNamed('params')),
    ).thenAnswer((_) async => RegisterModel.fromJson(kOtpChallengeJson()));
    await repository.register(params: registerParams);
    verifyNever(local.persistSession(any));
  });

  test('FR-009 register maps ServerException', () async {
    when(
      remote.register(params: anyNamed('params')),
    ).thenThrow(const ServerException(message: 'down'));
    final result = await repository.register(params: registerParams);
    expect(result.isLeft, isTrue);
    result.fold(
      (Failure f) => expect(f, isA<ServerFailure>()),
      (_) => fail('expected left'),
    );
  });

  test('FR-009 register maps ValidationException', () async {
    when(remote.register(params: anyNamed('params'))).thenThrow(
      const ValidationException(
        message: 'invalid',
        fieldErrors: <String, List<String>>{
          'email': <String>['taken'],
        },
      ),
    );
    final result = await repository.register(params: registerParams);
    result.fold((Failure f) {
      expect(f, isA<ValidationFailure>());
    }, (_) => fail('expected left'));
  });

  test('FR-010 register maps ConflictException', () async {
    when(
      remote.register(params: anyNamed('params')),
    ).thenThrow(const ConflictException(message: 'exists'));
    final result = await repository.register(params: registerParams);
    result.fold((Failure f) {
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, StatusCode.conflict);
    }, (_) => fail('expected left'));
  });

  test('FR-011 verifyEmail persists session', () async {
    when(
      remote.verifyEmail(params: anyNamed('params')),
    ).thenAnswer((_) async => VerifyEmailModel.fromJson(kSessionJson()));
    await repository.verifyEmail(params: const NoParams());
    verify(local.persistSession(any)).called(1);
  });

  test('FR-016 401 login maps to invalid_credentials', () async {
    when(
      remote.login(params: anyNamed('params')),
    ).thenThrow(const UnauthorizedException(message: 'nope'));
    final result = await repository.login(
      params: const LoginParams(email: 'a@b.c', password: 'x'),
    );
    result.fold((Failure f) {
      expect(f, isA<UnauthorizedFailure>());
      expect(f.message, Strings.invalidCredentials);
    }, (_) => fail('expected left'));
  });

  test('FR-015 login persists only on LoginSucceeded', () async {
    when(
      remote.login(params: anyNamed('params')),
    ).thenAnswer((_) async => LoginModel.fromJson(kSessionJson()));
    await repository.login(
      params: const LoginParams(email: 'a@b.c', password: 'x'),
    );
    verify(local.persistSession(any)).called(1);
  });

  test('FR-018a five OTP guesses map to 429 throttle', () async {
    when(
      remote.verifyEmail(params: anyNamed('params')),
    ).thenThrow(const TooManyRequestsException(message: 'slow'));
    final result = await repository.verifyEmail(params: const NoParams());
    result.fold((Failure f) {
      expect(f, isA<ServerFailure>());
      expect((f as ServerFailure).statusCode, StatusCode.tooManyRequests);
    }, (_) => fail('expected left'));
  });

  test('FR-043 logout still clears local when remote fails', () async {
    when(
      remote.logout(params: anyNamed('params')),
    ).thenThrow(const ServerException(message: 'down'));
    final result = await repository.logout(params: const NoParams());
    expect(result.isRight, isTrue);
    verify(local.clearSession()).called(1);
  });

  test('FR-037 continueAsGuest marks guest', () async {
    await repository.continueAsGuest(params: const NoParams());
    verify(local.markGuest()).called(1);
  });

  test('FR-021 auto-link session persists', () async {
    when(
      remote.verifyPhoneOtp(params: anyNamed('params')),
    ).thenAnswer((_) async => VerifyPhoneOtpModel.fromJson(kSessionJson()));
    await repository.verifyPhoneOtp(params: const NoParams());
    verify(local.persistSession(any)).called(1);
  });

  test('FR-023 registration_required persists draft', () async {
    when(remote.verifyPhoneOtp(params: anyNamed('params'))).thenAnswer(
      (_) async => VerifyPhoneOtpModel.fromJson(
        kRegistrationRequiredJson(RegistrationSource.phone),
      ),
    );
    await repository.verifyPhoneOtp(params: const NoParams());
    verify(local.saveRegistrationDraft(any)).called(1);
    verifyNever(local.persistSession(any));
  });

  test('FR-026a complete 409 maps to draft_expired', () async {
    when(
      remote.completeRegistration(params: anyNamed('params')),
    ).thenThrow(const ConflictException(message: 'gone'));
    final result = await repository.completeRegistration(
      params: const CompleteRegistrationParams(
        registrationToken: 'x',
        source: RegistrationSource.phone,
        fullName: 'Ada',
        password: 'secret12',
      ),
    );
    result.fold((Failure f) {
      expect(f.message, Strings.draftExpired);
    }, (_) => fail('expected left'));
  });

  test('FR-035 cancel does not persist a draft', () async {
    when(
      social.authorize(SocialProvider.google),
    ).thenThrow(const SocialSignInCancelledException());
    final result = await repository.socialSignIn(
      params: const SocialSignInParams(provider: SocialProvider.google),
    );
    expect(result.isLeft, isTrue);
    result.fold(
      (Failure f) => expect(f, isA<SocialSignInCancelledFailure>()),
      (_) => fail('expected left'),
    );
    verifyNever(local.saveRegistrationDraft(any));
    verifyNever(local.persistSession(any));
  });

  test('FR-035a other social failures map to social_failed', () async {
    when(
      social.authorize(SocialProvider.google),
    ).thenThrow(const ServerException(message: 'sdk'));
    final result = await repository.socialSignIn(
      params: const SocialSignInParams(provider: SocialProvider.google),
    );
    result.fold((Failure f) {
      expect(f.message, Strings.socialFailed);
    }, (_) => fail('expected left'));
  });

  test('FR-041 social session auto-link persists', () async {
    when(social.authorize(SocialProvider.google)).thenAnswer(
      (_) async => const SocialCredential(
        provider: SocialProvider.google,
        idToken: 'id',
        email: 'ada@example.com',
      ),
    );
    when(
      remote.socialSignIn(params: anyNamed('params')),
    ).thenAnswer((_) async => SocialSignInModel.fromJson(kSessionJson()));
    await repository.socialSignIn(
      params: const SocialSignInParams(provider: SocialProvider.google),
    );
    verify(local.persistSession(any)).called(1);
  });

  test('FR-046b requestPasswordReset same for unknown email', () async {
    when(remote.requestPasswordReset(params: anyNamed('params'))).thenAnswer(
      (_) async => RequestPasswordResetModel.fromJson(
        kOtpChallengeJson(purpose: 'reset_password'),
      ),
    );
    final result = await repository.requestPasswordReset(
      params: const NoParams(),
    );
    expect(result.isRight, isTrue);
  });

  test('FR-046d used-once reset code is conflict', () async {
    when(
      remote.resetPassword(params: anyNamed('params')),
    ).thenThrow(const ConflictException(message: 'used'));
    final result = await repository.resetPassword(params: const NoParams());
    result.fold((Failure f) {
      expect((f as ServerFailure).statusCode, StatusCode.conflict);
    }, (_) => fail('expected left'));
  });

  test('FR-046c resetPassword persists session', () async {
    when(
      remote.resetPassword(params: anyNamed('params')),
    ).thenAnswer((_) async => ResetPasswordModel.fromJson(kSessionJson()));
    await repository.resetPassword(params: const NoParams());
    verify(local.persistSession(any)).called(1);
  });

  test('FR-038 resolveVisitorState and readRegistrationDraft', () async {
    when(local.readVisitorState()).thenAnswer((_) async => UserType.guest);
    when(local.readRegistrationDraft()).thenAnswer((_) async => kPhoneDraft);
    expect(
      (await repository.resolveVisitorState(params: const NoParams())).isRight,
      isTrue,
    );
    expect(
      (await repository.readRegistrationDraft(params: const NoParams()))
          .isRight,
      isTrue,
    );
  });

  test('FR-043 logout maps local cache failure', () async {
    when(remote.logout(params: anyNamed('params'))).thenAnswer(
      (_) async => const LogoutModel(status: 'success', message: ''),
    );
    when(local.clearSession()).thenThrow(const CacheException());
    expect(
      (await repository.logout(params: const NoParams())).isLeft,
      isTrue,
    );
  });

  test('FR-012 requestEmailOtp and social with existing idToken', () async {
    when(remote.requestEmailOtp(params: anyNamed('params'))).thenAnswer(
      (_) async => RequestOtpModel.fromJson(kOtpChallengeJson()),
    );
    expect(
      (await repository.requestEmailOtp(params: const NoParams())).isRight,
      isTrue,
    );
    when(remote.socialSignIn(params: anyNamed('params'))).thenAnswer(
      (_) async => SocialSignInModel.fromJson(
        kRegistrationRequiredJson(RegistrationSource.google),
      ),
    );
    await repository.socialSignIn(
      params: const SocialSignInParams(
        provider: SocialProvider.google,
        idToken: 'already',
      ),
    );
    verifyNever(social.authorize(any));
    verify(local.saveRegistrationDraft(any)).called(1);
  });

  test('FR-021 verifyPhoneOtp ack has no persist', () async {
    when(remote.verifyPhoneOtp(params: anyNamed('params'))).thenAnswer(
      (_) async => const VerifyPhoneOtpModel(status: 'success', message: 'ok'),
    );
    await repository.verifyPhoneOtp(params: const NoParams());
    verifyNever(local.persistSession(any));
    verifyNever(local.saveRegistrationDraft(any));
  });

  test('FR-018a mapTooManyRequests copies throttle message', () {
    final Failure mapped = mapTooManyRequests(
      const ServerFailure(statusCode: StatusCode.tooManyRequests),
    );
    expect(mapped.message, Strings.tooManyAttempts);
    expect(mapTooManyRequests(const ServerFailure()), isA<ServerFailure>());
  });

  test('FR-038 continueAsGuest maps local failure', () async {
    when(local.markGuest()).thenThrow(const CacheException());
    expect(
      (await repository.continueAsGuest(params: const NoParams())).isLeft,
      isTrue,
    );
  });
}
