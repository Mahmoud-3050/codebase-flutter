import '../../../../core/usecases/usecase.dart';
import '../models/complete_registration_model.dart';
import '../models/login_model.dart';
import '../models/logout_model.dart';
import '../models/register_model.dart';
import '../models/request_otp_model.dart';
import '../models/request_password_reset_model.dart';
import '../models/reset_password_model.dart';
import '../models/social_sign_in_model.dart';
import '../models/verify_email_model.dart';
import '../models/verify_phone_otp_model.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterModel> register({required Params params});
  Future<LoginModel> login({required Params params});
  Future<VerifyEmailModel> verifyEmail({required Params params});
  Future<RequestOtpModel> requestEmailOtp({required Params params});
  Future<RequestOtpModel> requestPhoneOtp({required Params params});
  Future<VerifyPhoneOtpModel> verifyPhoneOtp({required Params params});
  Future<SocialSignInModel> socialSignIn({required Params params});
  Future<CompleteRegistrationModel> completeRegistration({
    required Params params,
  });
  Future<RequestPasswordResetModel> requestPasswordReset({
    required Params params,
  });
  Future<ResetPasswordModel> resetPassword({required Params params});
  Future<LogoutModel> logout({required Params params});
}
