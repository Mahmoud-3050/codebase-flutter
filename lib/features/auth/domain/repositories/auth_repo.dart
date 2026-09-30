import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/enums.dart';
import '../entities/complete_registration_response.dart';
import '../entities/login_response.dart';
import '../entities/logout_response.dart';
import '../entities/register_response.dart';
import '../entities/registration_draft.dart';
import '../entities/request_otp_response.dart';
import '../entities/request_password_reset_response.dart';
import '../entities/reset_password_response.dart';
import '../entities/social_sign_in_response.dart';
import '../entities/verify_email_response.dart';
import '../entities/verify_phone_otp_response.dart';

abstract class AuthRepository {
  Future<Either<Failure, RegisterResponse>> register({required Params params});
  Future<Either<Failure, LoginResponse>> login({required Params params});
  Future<Either<Failure, VerifyEmailResponse>> verifyEmail({
    required Params params,
  });
  Future<Either<Failure, RequestOtpResponse>> requestEmailOtp({
    required Params params,
  });
  Future<Either<Failure, RequestOtpResponse>> requestPhoneOtp({
    required Params params,
  });
  Future<Either<Failure, VerifyPhoneOtpResponse>> verifyPhoneOtp({
    required Params params,
  });
  Future<Either<Failure, SocialSignInResponse>> socialSignIn({
    required Params params,
  });
  Future<Either<Failure, CompleteRegistrationResponse>> completeRegistration({
    required Params params,
  });
  Future<Either<Failure, RequestPasswordResetResponse>> requestPasswordReset({
    required Params params,
  });
  Future<Either<Failure, ResetPasswordResponse>> resetPassword({
    required Params params,
  });
  Future<Either<Failure, LogoutResponse>> logout({required Params params});
  Future<Either<Failure, UserType>> resolveVisitorState({
    required Params params,
  });
  Future<Either<Failure, void>> continueAsGuest({required Params params});
  Future<Either<Failure, RegistrationDraft?>> readRegistrationDraft({
    required Params params,
  });
}
