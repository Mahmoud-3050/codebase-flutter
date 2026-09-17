import 'package:get_it/get_it.dart';

import '../../core/services/local_storage/impl/access_token_storage.dart';
import '../../core/services/local_storage/impl/registration_draft_storage.dart';
import '../../core/services/local_storage/impl/user_type_storage.dart';
import '../../injection_container.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/datasources/auth_local_datasource_impl.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_remote_datasource_impl.dart';
import 'data/datasources/avatar_picker_impl.dart';
import 'domain/avatar_picker.dart';
import 'data/datasources/social_auth_service.dart';
import 'data/datasources/social_auth_service_impl.dart';
import 'data/repositories/auth_repo_impl.dart';
import 'domain/repositories/auth_repo.dart';
import 'domain/usecases/complete_registration_usecase.dart';
import 'domain/usecases/continue_as_guest_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/read_registration_draft_usecase.dart';
import 'domain/usecases/register_usecase.dart';
import 'domain/usecases/request_email_otp_usecase.dart';
import 'domain/usecases/request_password_reset_usecase.dart';
import 'domain/usecases/request_phone_otp_usecase.dart';
import 'domain/usecases/reset_password_usecase.dart';
import 'domain/usecases/resolve_visitor_state_usecase.dart';
import 'domain/usecases/social_sign_in_usecase.dart';
import 'domain/usecases/verify_email_usecase.dart';
import 'domain/usecases/verify_phone_otp_usecase.dart';
import 'presentation/controller/complete_registration/complete_registration_cubit.dart';
import 'presentation/controller/guest_mode/guest_mode_cubit.dart';
import 'presentation/controller/login/login_cubit.dart';
import 'presentation/controller/logout/logout_cubit.dart';
import 'presentation/controller/otp_cooldown/otp_cooldown_cubit.dart';
import 'presentation/controller/read_registration_draft/read_registration_draft_cubit.dart';
import 'presentation/controller/register/register_cubit.dart';
import 'presentation/controller/request_email_otp/request_email_otp_cubit.dart';
import 'presentation/controller/request_password_reset/request_password_reset_cubit.dart';
import 'presentation/controller/request_phone_otp/request_phone_otp_cubit.dart';
import 'presentation/controller/reset_password/reset_password_cubit.dart';
import 'presentation/controller/resolve_visitor_state/resolve_visitor_state_cubit.dart';
import 'presentation/controller/social_sign_in/social_sign_in_cubit.dart';
import 'presentation/controller/verify_email/verify_email_cubit.dart';
import 'presentation/controller/verify_phone_otp/verify_phone_otp_cubit.dart';

void registerAuthDataLayer(GetIt sl) {
  sl.registerLazySingleton<RegistrationDraftStorage>(
    () => RegistrationDraftStorage(secureStorage: secureStorage),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(AuthRemoteDataSourceImpl.new);
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      accessTokenStorage: sl<AccessTokenStorage>(),
      userTypeStorage: sl<UserTypeStorage>(),
      registrationDraftStorage: sl<RegistrationDraftStorage>(),
    ),
  );
  sl.registerLazySingleton<SocialAuthService>(SocialAuthServiceImpl.new);
  sl.registerLazySingleton<AvatarPicker>(AvatarPickerImpl.new);
  sl.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(remote: sl(), local: sl(), socialAuthService: sl()),
  );
}

void registerVisitorState(GetIt sl) {
  sl.registerLazySingleton<ResolveVisitorStateUseCase>(
    () => ResolveVisitorStateUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ContinueAsGuestUseCase>(
    () => ContinueAsGuestUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ReadRegistrationDraftUseCase>(
    () => ReadRegistrationDraftUseCase(repository: sl()),
  );
  sl.registerFactory<ResolveVisitorStateCubit>(
    () => ResolveVisitorStateCubit(sl()),
  );
  sl.registerFactory<GuestModeCubit>(() => GuestModeCubit(sl()));
  sl.registerFactory<ReadRegistrationDraftCubit>(
    () => ReadRegistrationDraftCubit(sl()),
  );
}

void registerRegister(GetIt sl) {
  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: sl()),
  );
  sl.registerFactory<RegisterCubit>(() => RegisterCubit(sl()));
}

void registerVerifyEmail(GetIt sl) {
  sl.registerLazySingleton<VerifyEmailUseCase>(
    () => VerifyEmailUseCase(repository: sl()),
  );
  sl.registerLazySingleton<RequestEmailOtpUseCase>(
    () => RequestEmailOtpUseCase(repository: sl()),
  );
  sl.registerFactory<VerifyEmailCubit>(() => VerifyEmailCubit(sl()));
  sl.registerFactory<RequestEmailOtpCubit>(() => RequestEmailOtpCubit(sl()));
}

void registerOtpCooldown(GetIt sl) {
  sl.registerFactory<OtpCooldownCubit>(
    () => OtpCooldownCubit(tick: OtpCooldownCubit.periodicTick),
  );
}

void registerLogin(GetIt sl) {
  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(repository: sl()));
  sl.registerFactory<LoginCubit>(() => LoginCubit(sl()));
}

void registerPhoneSignIn(GetIt sl) {
  sl.registerLazySingleton<RequestPhoneOtpUseCase>(
    () => RequestPhoneOtpUseCase(repository: sl()),
  );
  sl.registerLazySingleton<VerifyPhoneOtpUseCase>(
    () => VerifyPhoneOtpUseCase(repository: sl()),
  );
  sl.registerFactory<RequestPhoneOtpCubit>(() => RequestPhoneOtpCubit(sl()));
  sl.registerFactory<VerifyPhoneOtpCubit>(() => VerifyPhoneOtpCubit(sl()));
}

void registerCompleteRegistration(GetIt sl) {
  sl.registerLazySingleton<CompleteRegistrationUseCase>(
    () => CompleteRegistrationUseCase(repository: sl()),
  );
  sl.registerFactory<CompleteRegistrationCubit>(
    () => CompleteRegistrationCubit(sl()),
  );
}

void registerSocialSignIn(GetIt sl) {
  sl.registerLazySingleton<SocialSignInUseCase>(
    () => SocialSignInUseCase(repository: sl()),
  );
  sl.registerFactory<SocialSignInCubit>(() => SocialSignInCubit(sl()));
}

void registerPasswordRecovery(GetIt sl) {
  sl.registerLazySingleton<RequestPasswordResetUseCase>(
    () => RequestPasswordResetUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(repository: sl()),
  );
  sl.registerFactory<RequestPasswordResetCubit>(
    () => RequestPasswordResetCubit(sl()),
  );
  sl.registerFactory<ResetPasswordCubit>(() => ResetPasswordCubit(sl()));
}

void registerLogout(GetIt sl) {
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl()),
  );
  sl.registerFactory<LogoutCubit>(() => LogoutCubit(sl()));
}
