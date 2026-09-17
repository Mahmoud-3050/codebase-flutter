import 'package:either/either.dart';
import 'package:mockito/mockito.dart';

import 'package:codebase/core/error/failures.dart';
import 'package:codebase/core/utils/enums.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service.dart';
import 'package:codebase/features/auth/domain/entities/complete_registration_response.dart';
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
import 'package:codebase/features/auth/domain/enums/social_provider.dart';

void ensureAuthDummies() {
  provideDummy<Either<Failure, RegisterResponse>>(
    const Left<Failure, RegisterResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, LoginResponse>>(
    const Left<Failure, LoginResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, VerifyEmailResponse>>(
    const Left<Failure, VerifyEmailResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, RequestOtpResponse>>(
    const Left<Failure, RequestOtpResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, VerifyPhoneOtpResponse>>(
    const Left<Failure, VerifyPhoneOtpResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, SocialSignInResponse>>(
    const Left<Failure, SocialSignInResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, CompleteRegistrationResponse>>(
    const Left<Failure, CompleteRegistrationResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, RequestPasswordResetResponse>>(
    const Left<Failure, RequestPasswordResetResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, ResetPasswordResponse>>(
    const Left<Failure, ResetPasswordResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, LogoutResponse>>(
    const Left<Failure, LogoutResponse>(ServerFailure()),
  );
  provideDummy<Either<Failure, void>>(const Left<Failure, void>(ServerFailure()));
  provideDummy<Either<Failure, UserType>>(
    const Left<Failure, UserType>(ServerFailure()),
  );
  provideDummy<Either<Failure, RegistrationDraft?>>(
    const Left<Failure, RegistrationDraft?>(ServerFailure()),
  );
  provideDummy<SocialCredential>(
    const SocialCredential(
      provider: SocialProvider.google,
      idToken: 'dummy',
    ),
  );
}
