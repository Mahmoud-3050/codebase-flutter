import 'package:either/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/auth_injection.dart';
import 'package:codebase/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:codebase/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:codebase/features/auth/domain/avatar_picker.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service.dart';
import 'package:codebase/features/auth/data/models/auth_json.dart';
import 'package:codebase/features/auth/data/models/auth_user_model.dart';
import 'package:codebase/features/auth/domain/entities/auth_outcome.dart';
import 'package:codebase/features/auth/domain/entities/auth_session.dart';
import 'package:codebase/features/auth/domain/entities/complete_registration_response.dart';
import 'package:codebase/features/auth/domain/entities/login_outcome.dart';
import 'package:codebase/features/auth/domain/entities/login_response.dart';
import 'package:codebase/features/auth/domain/entities/logout_response.dart';
import 'package:codebase/features/auth/domain/entities/register_response.dart';
import 'package:codebase/features/auth/domain/entities/registration_draft.dart';
import 'package:codebase/features/auth/domain/entities/request_otp_response.dart';
import 'package:codebase/features/auth/domain/entities/request_password_reset_response.dart';
import 'package:codebase/features/auth/domain/entities/reset_password_response.dart';
import 'package:codebase/features/auth/domain/entities/social_sign_in_response.dart';
import 'package:codebase/features/auth/domain/entities/verify_email_response.dart';
import 'package:codebase/features/auth/domain/entities/verify_phone_otp_response.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';
import 'package:codebase/features/auth/domain/enums/social_provider.dart';
import 'package:codebase/features/auth/domain/repositories/auth_repo.dart';
import 'package:codebase/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/read_registration_draft_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/register_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_email_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_phone_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/resolve_visitor_state_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/social_sign_in_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_phone_otp_usecase.dart';
import 'package:codebase/features/auth/presentation/auth_error_copy.dart';
import 'package:codebase/features/auth/presentation/controller/complete_registration/complete_registration_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/guest_mode/guest_mode_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/login/login_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/logout/logout_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/otp_cooldown/otp_cooldown_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/read_registration_draft/read_registration_draft_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/register/register_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_email_otp/request_email_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_password_reset/request_password_reset_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/request_phone_otp/request_phone_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/reset_password/reset_password_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/resolve_visitor_state/resolve_visitor_state_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/social_sign_in/social_sign_in_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/verify_email/verify_email_cubit.dart';
import 'package:codebase/features/auth/presentation/controller/verify_phone_otp/verify_phone_otp_cubit.dart';
import 'package:codebase/features/auth/presentation/social_provider_availability.dart';

import 'dummy_eithers.dart';
import 'fixtures.dart';
import 'mocks.mocks.dart';

void main() {
  setUpAll(ensureAuthDummies);

  test(
    'FR-003 FR-006 FR-020 FR-022 FR-027 FR-028 FR-032 FR-034a FR-038 FR-040 FR-042 named coverage',
    () {
      expect(SocialProvider.fromWireName('google'), SocialProvider.google);
      expect(SocialProvider.fromWireName('apple'), SocialProvider.apple);
      expect(SocialProvider.fromWireName('unknown'), SocialProvider.google);
      expect(OtpPurpose.fromWireName('phone_sign_in'), OtpPurpose.phoneSignIn);
      expect(OtpPurpose.fromWireName('nope'), OtpPurpose.verifyEmail);
      expect(
        RegistrationSource.fromWireName('google'),
        RegistrationSource.google,
      );
      expect(RegistrationSource.fromWireName('x'), RegistrationSource.phone);
      expect(RegistrationSource.phone.locksPhone, isTrue);
      expect(RegistrationSource.google.locksEmail, isTrue);
      expect(
        SocialProviderAvailability.isOffered(
          SocialProvider.apple,
          platform: TargetPlatform.macOS,
        ),
        isTrue,
      );
      expect(
        const AvatarRejectedException(
          reason: AvatarRejectReason.tooLarge,
        ).reason,
        AvatarRejectReason.tooLarge,
      );
      expect(
        const SocialCredential(
          provider: SocialProvider.apple,
          idToken: 'id',
          authorizationCode: 'code',
          fullName: 'Ada',
          email: 'relay@privaterelay.appleid.com',
        ).props,
        isNotEmpty,
      );
    },
  );

  test('FR-006 required fields and optional avatar are modeled', () {
    expect(kUnverifiedUser.avatarUrl, isNull);
    expect(kUnverifiedUser.email, isNotEmpty);
    expect(kPhoneDraft.verifiedPhone, isNotEmpty);
  });

  test(
    'FR-020 phone_sign_in purpose is required on every phone OTP request',
    () {
      expect(
        const RequestPhoneOtpParams(
          dialingCode: '+966',
          phone: '500000000',
        ).toJson()['purpose'],
        'phone_sign_in',
      );
    },
  );

  test('FR-022 complete-registration params collect name email password', () {
    final CompleteRegistrationParams params = CompleteRegistrationParams(
      registrationToken: 'tok',
      source: RegistrationSource.phone,
      fullName: 'Ada',
      password: 'secret12',
      email: 'ada@example.com',
      dialingCode: '+966',
      phone: '500000000',
    );
    expect(params.toJson()['email'], 'ada@example.com');
    expect(params.props, contains('Ada'));
  });

  test('response entities expose props', () {
    expect(
      const RegisterResponse(
        status: 'success',
        message: 'ok',
        data: kEmailChallenge,
      ).props,
      isNotEmpty,
    );
    expect(
      LoginResponse(
        status: 'success',
        message: 'ok',
        data: LoginSucceeded(kSession),
      ).props,
      isNotEmpty,
    );
    expect(
      VerifyEmailResponse(
        status: 'success',
        message: 'ok',
        data: kSession,
      ).props,
      isNotEmpty,
    );
    expect(
      const RequestOtpResponse(
        status: 'success',
        message: 'ok',
        data: kEmailChallenge,
      ).props,
      isNotEmpty,
    );
    expect(
      const VerifyPhoneOtpResponse(status: 'success', message: 'ok').props,
      isNotEmpty,
    );
    expect(
      SocialSignInResponse(
        status: 'success',
        message: 'ok',
        data: AuthSessionEstablished(kSession),
      ).props,
      isNotEmpty,
    );
    expect(
      CompleteRegistrationResponse(
        status: 'success',
        message: 'ok',
        data: kSession,
      ).props,
      isNotEmpty,
    );
    expect(
      const RequestPasswordResetResponse(
        status: 'success',
        message: 'ok',
        data: kEmailChallenge,
      ).props,
      isNotEmpty,
    );
    expect(
      ResetPasswordResponse(
        status: 'success',
        message: 'ok',
        data: kSession,
      ).props,
      isNotEmpty,
    );
    expect(
      const LogoutResponse(status: 'success', message: '').props,
      isNotEmpty,
    );
  });

  test('FR-049 AuthErrorCopy maps conflict and fallback', () {
    expect(
      AuthErrorCopy.of(const ServerFailure(statusCode: StatusCode.conflict)),
      Strings.emailTaken,
    );
    expect(
      AuthErrorCopy.of(
        const ServerFailure(statusCode: StatusCode.conflict),
        draftConflict: true,
      ),
      Strings.draftExpired,
    );
    expect(
      AuthErrorCopy.of(const ServerFailure()),
      Strings.pleaseTryAgainLater,
    );
  });

  test('FR-003 register* functions register feature types', () {
    final GetIt sl = GetIt.asNewInstance();
    sl.registerLazySingleton<AuthRepository>(MockAuthRepository.new);
    registerVisitorState(sl);
    registerRegister(sl);
    registerVerifyEmail(sl);
    registerOtpCooldown(sl);
    registerLogin(sl);
    registerPhoneSignIn(sl);
    registerCompleteRegistration(sl);
    registerSocialSignIn(sl);
    registerPasswordRecovery(sl);
    registerLogout(sl);
    expect(sl<ResolveVisitorStateCubit>(), isA<ResolveVisitorStateCubit>());
    expect(sl<GuestModeCubit>(), isA<GuestModeCubit>());
    expect(sl<ReadRegistrationDraftCubit>(), isA<ReadRegistrationDraftCubit>());
    expect(sl<RegisterCubit>(), isA<RegisterCubit>());
    expect(sl<VerifyEmailCubit>(), isA<VerifyEmailCubit>());
    expect(sl<RequestEmailOtpCubit>(), isA<RequestEmailOtpCubit>());
    expect(sl<OtpCooldownCubit>(), isA<OtpCooldownCubit>());
    expect(sl<LoginCubit>(), isA<LoginCubit>());
    expect(sl<RequestPhoneOtpCubit>(), isA<RequestPhoneOtpCubit>());
    expect(sl<VerifyPhoneOtpCubit>(), isA<VerifyPhoneOtpCubit>());
    expect(sl<CompleteRegistrationCubit>(), isA<CompleteRegistrationCubit>());
    expect(sl<SocialSignInCubit>(), isA<SocialSignInCubit>());
    expect(sl<RequestPasswordResetCubit>(), isA<RequestPasswordResetCubit>());
    expect(sl<ResetPasswordCubit>(), isA<ResetPasswordCubit>());
    expect(sl<LogoutCubit>(), isA<LogoutCubit>());
  });

  test('FR-003 registerAuthDataLayer registers data contracts', () {
    final GetIt sl = GetIt.asNewInstance();
    registerAuthDataLayer(sl);
    expect(sl.isRegistered<AuthRemoteDataSource>(), isTrue);
    expect(sl.isRegistered<AuthLocalDataSource>(), isTrue);
    expect(sl.isRegistered<AuthRepository>(), isTrue);
    expect(sl.isRegistered<SocialAuthService>(), isTrue);
    expect(sl.isRegistered<AvatarPicker>(), isTrue);
  });

  test('FR-038 FR-042 remaining use cases delegate', () async {
    final MockAuthRepository repository = MockAuthRepository();
    when(
      repository.resolveVisitorState(params: anyNamed('params')),
    ).thenAnswer((_) async => const Right<Failure, UserType>(UserType.guest));
    when(
      repository.readRegistrationDraft(params: anyNamed('params')),
    ).thenAnswer((_) async => Right<Failure, RegistrationDraft?>(kPhoneDraft));
    when(repository.requestPhoneOtp(params: anyNamed('params'))).thenAnswer(
      (_) async => const Right<Failure, RequestOtpResponse>(
        RequestOtpResponse(
          status: 'success',
          message: 'ok',
          data: kPhoneChallenge,
        ),
      ),
    );
    when(repository.verifyPhoneOtp(params: anyNamed('params'))).thenAnswer(
      (_) async => const Right<Failure, VerifyPhoneOtpResponse>(
        VerifyPhoneOtpResponse(status: 'success', message: 'ok'),
      ),
    );
    when(
      repository.completeRegistration(params: anyNamed('params')),
    ).thenAnswer(
      (_) async => Right<Failure, CompleteRegistrationResponse>(
        CompleteRegistrationResponse(
          status: 'success',
          message: 'ok',
          data: kSession,
        ),
      ),
    );
    when(repository.socialSignIn(params: anyNamed('params'))).thenAnswer(
      (_) async => Right<Failure, SocialSignInResponse>(
        SocialSignInResponse(
          status: 'success',
          message: 'ok',
          data: AuthSessionEstablished(kSession),
        ),
      ),
    );
    when(
      repository.requestPasswordReset(params: anyNamed('params')),
    ).thenAnswer(
      (_) async => const Right<Failure, RequestPasswordResetResponse>(
        RequestPasswordResetResponse(
          status: 'success',
          message: 'ok',
          data: kEmailChallenge,
        ),
      ),
    );
    when(repository.resetPassword(params: anyNamed('params'))).thenAnswer(
      (_) async => Right<Failure, ResetPasswordResponse>(
        ResetPasswordResponse(status: 'success', message: 'ok', data: kSession),
      ),
    );

    expect(
      (await ResolveVisitorStateUseCase(repository: repository)(
        const NoParams(),
      )).isRight,
      isTrue,
    );
    expect(
      (await ReadRegistrationDraftUseCase(repository: repository)(
        const NoParams(),
      )).isRight,
      isTrue,
    );
    expect(
      (await RequestPhoneOtpUseCase(repository: repository)(
        const RequestPhoneOtpParams(dialingCode: '+966', phone: '500000000'),
      )).isRight,
      isTrue,
    );
    expect(
      (await VerifyPhoneOtpUseCase(repository: repository)(
        const VerifyPhoneOtpParams(
          dialingCode: '+966',
          phone: '500000000',
          code: kValidOtpCode,
          purpose: OtpPurpose.phoneSignIn,
        ),
      )).isRight,
      isTrue,
    );
    expect(
      (await CompleteRegistrationUseCase(repository: repository)(
        const CompleteRegistrationParams(
          registrationToken: 'tok',
          source: RegistrationSource.phone,
          fullName: 'Ada',
          password: 'secret12',
        ),
      )).isRight,
      isTrue,
    );
    expect(
      (await SocialSignInUseCase(repository: repository)(
        const SocialSignInParams(provider: SocialProvider.google),
      )).isRight,
      isTrue,
    );
    expect(
      (await RequestPasswordResetUseCase(repository: repository)(
        const RequestPasswordResetParams(email: 'ada@example.com'),
      )).isRight,
      isTrue,
    );
    expect(
      (await ResetPasswordUseCase(repository: repository)(
        const ResetPasswordParams(
          email: 'ada@example.com',
          code: kValidOtpCode,
          password: 'secret12',
        ),
      )).isRight,
      isTrue,
    );
  });

  test('FR-040 params props and optional toJson fields', () {
    expect(
      const RegisterParams(
        fullName: 'Ada',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret12',
        avatarPath: '/a.png',
        cancellation: 'c',
      ).props,
      isNotEmpty,
    );
    expect(
      const LoginParams(email: 'a@b.c', password: 'x', cancellation: 'c').props,
      contains('a@b.c'),
    );
    expect(
      const VerifyEmailParams(
        email: 'a@b.c',
        code: '123456',
        cancellation: 'c',
      ).props,
      isNotEmpty,
    );
    expect(
      const RequestEmailOtpParams(email: 'a@b.c', cancellation: 'c').props,
      isNotEmpty,
    );
    expect(
      const RequestPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        cancellation: 'c',
      ).props,
      isNotEmpty,
    );
    expect(
      const VerifyPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        code: '123456',
        purpose: OtpPurpose.phoneSignIn,
        cancellation: 'c',
      ).props,
      isNotEmpty,
    );
    const SocialSignInParams social = SocialSignInParams(
      provider: SocialProvider.apple,
      idToken: 'id',
      authorizationCode: 'code',
      fullName: 'Ada',
      email: 'a@b.c',
      cancellation: 'c',
    );
    expect(social.toJson()['id_token'], 'id');
    expect(social.toJson()['authorization_code'], 'code');
    expect(social.toJson()['full_name'], 'Ada');
    expect(social.props, contains('id'));
    expect(
      const RequestPasswordResetParams(email: 'a@b.c', cancellation: 'c').props,
      isNotEmpty,
    );
    expect(
      const ResetPasswordParams(
        email: 'a@b.c',
        code: '123456',
        password: 'secret12',
        cancellation: 'c',
      ).props,
      isNotEmpty,
    );
    expect(
      const CompleteRegistrationParams(
        registrationToken: 't',
        source: RegistrationSource.google,
        fullName: 'Ada',
        password: 'secret12',
        avatarPath: '/a.png',
        cancellation: 'c',
      ).props,
      contains('/a.png'),
    );
  });

  test('FR-042 session parser reads root token and empty avatar', () {
    final AuthSession session = parseAuthSession(<String, dynamic>{
      'status': 'success',
      'token': 'root-token',
      'data': <String, dynamic>{
        'user': <String, dynamic>{
          'id': 9,
          'full_name': 'Ada',
          'email': 'a@b.c',
          'dialing_code': '+966',
          'phone': '500000000',
          'email_verified': true,
          'phone_verified': true,
          'created_at': 'not-a-date',
          'avatar_url': '',
        },
      },
    });
    expect(session.accessToken, 'root-token');
    expect(session.user.avatarUrl, isNull);
    expect(
      parseRegistrationDraft(<String, dynamic>{
        'registration_token': 't',
        'source': 'phone',
        'verified_email': '',
      }).verifiedEmail,
      isNull,
    );
    expect(AuthUserModel.fromJson(<String, dynamic>{}).id, 0);
  });
}
