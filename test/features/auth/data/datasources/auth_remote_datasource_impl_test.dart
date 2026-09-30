import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/usecases/usecase.dart';
import 'package:codebase/features/auth/data/datasources/auth_remote_datasource_impl.dart';
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
import 'package:codebase/features/auth/domain/usecases/verify_phone_otp_usecase.dart';

import '../../fixtures.dart';
import '../../mocks.mocks.dart';

void main() {
  late MockDioConsumer client;
  late AuthRemoteDataSourceImpl remote;

  setUp(() {
    client = MockDioConsumer();
    remote = AuthRemoteDataSourceImpl(client: client);
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kOtpChallengeJson());
  });

  test('FR-008 register posts to registerPath', () async {
    await remote.register(
      params: const RegisterParams(
        fullName: 'Ada',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret12',
      ),
    );
    verify(
      client.post(
        ApiConstants.registerPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-015 login posts to loginPath', () async {
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kSessionJson());
    await remote.login(
      params: const LoginParams(email: 'a@b.c', password: 'x'),
    );
    verify(
      client.post(
        ApiConstants.loginPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-011 verifyEmail posts', () async {
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kSessionJson());
    await remote.verifyEmail(
      params: const VerifyEmailParams(email: 'a@b.c', code: '123456'),
    );
    verify(
      client.post(
        ApiConstants.verifyEmailPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-012 requestEmailOtp posts', () async {
    await remote.requestEmailOtp(
      params: const RequestEmailOtpParams(email: 'a@b.c'),
    );
    verify(
      client.post(
        ApiConstants.emailOtpRequestPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-019 requestPhoneOtp posts', () async {
    await remote.requestPhoneOtp(
      params: const RequestPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
      ),
    );
    verify(
      client.post(
        ApiConstants.phoneOtpRequestPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-021 verifyPhoneOtp posts', () async {
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kSessionJson());
    await remote.verifyPhoneOtp(
      params: const VerifyPhoneOtpParams(
        dialingCode: '+966',
        phone: '500000000',
        code: '123456',
        purpose: OtpPurpose.phoneSignIn,
      ),
    );
    verify(
      client.post(
        ApiConstants.verifyPhoneNumberPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-030 socialSignIn posts', () async {
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kSessionJson());
    await remote.socialSignIn(
      params: const SocialSignInParams(provider: SocialProvider.google),
    );
    verify(
      client.post(
        ApiConstants.socialSignInPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-025 completeRegistration posts', () async {
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kSessionJson());
    await remote.completeRegistration(
      params: const CompleteRegistrationParams(
        registrationToken: 't',
        source: RegistrationSource.phone,
        fullName: 'Ada',
        password: 'secret12',
      ),
    );
    verify(
      client.post(
        ApiConstants.completeRegistrationPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-046 requestPasswordReset and resetPassword post', () async {
    await remote.requestPasswordReset(
      params: const RequestPasswordResetParams(email: 'a@b.c'),
    );
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kSessionJson());
    await remote.resetPassword(
      params: const ResetPasswordParams(
        email: 'a@b.c',
        code: '123456',
        password: 'secret12',
      ),
    );
    await remote.logout(params: const NoParams());
    verify(
      client.post(
        ApiConstants.forgotPasswordPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
    verify(
      client.post(
        ApiConstants.resetPasswordPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
    verify(
      client.post(
        ApiConstants.logoutPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
  });

  test('FR-006 avatar multipart register and failed body', () async {
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer((_) async => kOtpChallengeJson());
    final File avatar = File('${Directory.systemTemp.path}/auth-avatar.png');
    await avatar.writeAsBytes(<int>[137, 80, 78, 71]);
    addTearDown(() {
      if (avatar.existsSync()) {
        avatar.deleteSync();
      }
    });
    await remote.register(
      params: RegisterParams(
        fullName: 'Ada',
        email: 'a@b.c',
        dialingCode: '+966',
        phone: '500000000',
        password: 'secret12',
        avatarPath: avatar.path,
      ),
    );
    verify(
      client.post(
        ApiConstants.registerPath,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).called(1);
    when(
      client.post(
        any,
        body: anyNamed('body'),
        formData: anyNamed('formData'),
        queryParameters: anyNamed('queryParameters'),
        cancelToken: anyNamed('cancelToken'),
      ),
    ).thenAnswer(
      (_) async => <String, dynamic>{'status': 'error', 'message': 'nope'},
    );
    expect(
      () => remote.login(
        params: const LoginParams(email: 'a@b.c', password: 'x'),
      ),
      throwsA(isA<ServerException>()),
    );
  });
}
