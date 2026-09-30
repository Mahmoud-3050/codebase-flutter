import 'package:mockito/annotations.dart';

import 'package:codebase/core/api/dio_consumer.dart';
import 'package:codebase/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:codebase/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:codebase/features/auth/data/datasources/social_auth_service.dart';
import 'package:codebase/features/auth/domain/avatar_picker.dart';
import 'package:codebase/features/auth/domain/repositories/auth_repo.dart';
import 'package:codebase/features/auth/domain/usecases/complete_registration_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/continue_as_guest_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/login_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/logout_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/read_registration_draft_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/register_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_email_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_password_reset_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/request_phone_otp_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/resolve_visitor_state_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/social_sign_in_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_email_usecase.dart';
import 'package:codebase/features/auth/domain/usecases/verify_phone_otp_usecase.dart';

@GenerateMocks(<Type>[
  AuthRemoteDataSource,
  AuthLocalDataSource,
  AuthRepository,
  SocialAuthService,
  AvatarPicker,
  DioConsumer,
  ResolveVisitorStateUseCase,
  RegisterUseCase,
  VerifyEmailUseCase,
  RequestEmailOtpUseCase,
  LoginUseCase,
  ContinueAsGuestUseCase,
  LogoutUseCase,
  RequestPhoneOtpUseCase,
  VerifyPhoneOtpUseCase,
  CompleteRegistrationUseCase,
  SocialSignInUseCase,
  RequestPasswordResetUseCase,
  ResetPasswordUseCase,
  ReadRegistrationDraftUseCase,
])
void main() {}
