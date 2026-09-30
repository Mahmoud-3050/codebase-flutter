import 'package:either/either.dart';

import '../../../../config/language/strings.dart';
import '../../../../core/api/status_code.dart';
import '../../../../core/data/repository_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../../domain/entities/auth_outcome.dart';
import '../../domain/entities/complete_registration_response.dart';
import '../../domain/entities/login_outcome.dart';
import '../../domain/entities/login_response.dart';
import '../../domain/entities/logout_response.dart';
import '../../domain/entities/register_response.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/entities/request_otp_response.dart';
import '../../domain/entities/request_password_reset_response.dart';
import '../../domain/entities/reset_password_response.dart';
import '../../domain/entities/social_sign_in_response.dart';
import '../../domain/entities/verify_email_response.dart';
import '../../domain/entities/verify_phone_otp_response.dart';
import '../../domain/repositories/auth_repo.dart';
import '../../domain/usecases/social_sign_in_usecase.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/social_auth_service.dart';

class AuthRepositoryImpl with RepositoryGuard implements AuthRepository {
  AuthRepositoryImpl({
    required this.remote,
    required this.local,
    required this.socialAuthService,
  });

  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;
  final SocialAuthService socialAuthService;

  @override
  Future<Either<Failure, RegisterResponse>> register({
    required Params params,
  }) => guard(() => remote.register(params: params), 'register');

  @override
  Future<Either<Failure, LoginResponse>> login({required Params params}) {
    return guard(() async {
      try {
        final LoginResponse response = await remote.login(params: params);
        if (response.data is LoginSucceeded) {
          await local.persistSession((response.data as LoginSucceeded).session);
        }
        return response;
      } on UnauthorizedException {
        throw const UnauthorizedException();
      }
    }, 'login').then(_mapLoginCredentials);
  }

  Either<Failure, LoginResponse> _mapLoginCredentials(
    Either<Failure, LoginResponse> result,
  ) {
    return result.fold((Failure failure) {
      if (failure is UnauthorizedFailure) {
        return Left<Failure, LoginResponse>(
          UnauthorizedFailure(message: Strings.invalidCredentials),
        );
      }
      return Left<Failure, LoginResponse>(failure);
    }, Right<Failure, LoginResponse>.new);
  }

  @override
  Future<Either<Failure, VerifyEmailResponse>> verifyEmail({
    required Params params,
  }) {
    return guard(() async {
      final VerifyEmailResponse response = await remote.verifyEmail(
        params: params,
      );
      await local.persistSession(response.data);
      return response;
    }, 'verifyEmail');
  }

  @override
  Future<Either<Failure, RequestOtpResponse>> requestEmailOtp({
    required Params params,
  }) => guard(() => remote.requestEmailOtp(params: params), 'requestEmailOtp');

  @override
  Future<Either<Failure, RequestOtpResponse>> requestPhoneOtp({
    required Params params,
  }) => guard(() => remote.requestPhoneOtp(params: params), 'requestPhoneOtp');

  @override
  Future<Either<Failure, VerifyPhoneOtpResponse>> verifyPhoneOtp({
    required Params params,
  }) {
    return guard(() async {
      final VerifyPhoneOtpResponse response = await remote.verifyPhoneOtp(
        params: params,
      );
      await _persistOutcome(response.data);
      return response;
    }, 'verifyPhoneOtp');
  }

  @override
  Future<Either<Failure, SocialSignInResponse>> socialSignIn({
    required Params params,
  }) async {
    SocialSignInParams exchange = params is SocialSignInParams
        ? params
        : throw ArgumentError('SocialSignInParams required');
    if (exchange.idToken == null) {
      try {
        final SocialCredential credential = await socialAuthService.authorize(
          exchange.provider,
        );
        exchange = SocialSignInParams(
          provider: exchange.provider,
          idToken: credential.idToken,
          authorizationCode: credential.authorizationCode,
          fullName: credential.fullName,
          email: credential.email,
          cancellation: exchange.cancellation,
        );
      } on SocialSignInCancelledException catch (error) {
        return Left<Failure, SocialSignInResponse>(error.toFailure());
      } on AppException catch (error) {
        return Left<Failure, SocialSignInResponse>(
          ServerFailure(
            message: Strings.socialFailed,
            statusCode: error is ServerException ? error.statusCode : null,
          ),
        );
      }
    }
    return guard(() async {
      final SocialSignInResponse response = await remote.socialSignIn(
        params: exchange,
      );
      await _persistOutcome(response.data);
      return response;
    }, 'socialSignIn');
  }

  Future<void> _persistOutcome(AuthOutcome? outcome) async {
    switch (outcome) {
      case AuthSessionEstablished(:final session):
        await local.persistSession(session);
      case AuthRegistrationRequired(:final draft):
        await local.saveRegistrationDraft(draft);
      case null:
        break;
    }
  }

  @override
  Future<Either<Failure, CompleteRegistrationResponse>> completeRegistration({
    required Params params,
  }) {
    return guard(() async {
      try {
        final CompleteRegistrationResponse response = await remote
            .completeRegistration(params: params);
        await local.persistSession(response.data);
        await local.clearRegistrationDraft();
        return response;
      } on ConflictException {
        throw ConflictException(message: Strings.draftExpired);
      }
    }, 'completeRegistration');
  }

  @override
  Future<Either<Failure, RequestPasswordResetResponse>> requestPasswordReset({
    required Params params,
  }) => guard(
    () => remote.requestPasswordReset(params: params),
    'requestPasswordReset',
  );

  @override
  Future<Either<Failure, ResetPasswordResponse>> resetPassword({
    required Params params,
  }) {
    return guard(() async {
      final ResetPasswordResponse response = await remote.resetPassword(
        params: params,
      );
      await local.persistSession(response.data);
      return response;
    }, 'resetPassword');
  }

  @override
  Future<Either<Failure, LogoutResponse>> logout({
    required Params params,
  }) async {
    LogoutResponse remoteResult = const LogoutResponse(
      status: 'success',
      message: '',
    );
    try {
      remoteResult = await remote.logout(params: params);
    } on AppException {
      // Local sign-out still proceeds (FR-043).
    }
    try {
      await local.clearSession();
      return Right<Failure, LogoutResponse>(remoteResult);
    } on AppException catch (error) {
      return Left<Failure, LogoutResponse>(error.toFailure());
    }
  }

  @override
  Future<Either<Failure, UserType>> resolveVisitorState({
    required Params params,
  }) {
    return guard(local.readVisitorState, 'resolveVisitorState');
  }

  @override
  Future<Either<Failure, void>> continueAsGuest({required Params params}) {
    return guard(local.markGuest, 'continueAsGuest');
  }

  @override
  Future<Either<Failure, RegistrationDraft?>> readRegistrationDraft({
    required Params params,
  }) {
    return guard(local.readRegistrationDraft, 'readRegistrationDraft');
  }
}

Failure mapTooManyRequests(Failure failure) {
  if (failure is ServerFailure &&
      failure.statusCode == StatusCode.tooManyRequests) {
    return ServerFailure(
      message: Strings.tooManyAttempts,
      statusCode: failure.statusCode,
    );
  }
  return failure;
}
