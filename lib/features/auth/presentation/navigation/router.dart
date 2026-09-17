import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes/app_routes.dart';
import '../../../../core/di/feature_scope.dart';
import '../../../../injection_container.dart';
import '../../auth_injection.dart';
import '../../domain/entities/registration_draft.dart';
import '../../domain/enums/otp_purpose.dart';
import '../controller/complete_registration/complete_registration_cubit.dart';
import '../controller/guest_mode/guest_mode_cubit.dart';
import '../controller/login/login_cubit.dart';
import '../controller/otp_cooldown/otp_cooldown_cubit.dart';
import '../controller/register/register_cubit.dart';
import '../controller/request_email_otp/request_email_otp_cubit.dart';
import '../controller/request_password_reset/request_password_reset_cubit.dart';
import '../controller/request_phone_otp/request_phone_otp_cubit.dart';
import '../controller/reset_password/reset_password_cubit.dart';
import '../controller/social_sign_in/social_sign_in_cubit.dart';
import '../controller/verify_email/verify_email_cubit.dart';
import '../controller/verify_phone_otp/verify_phone_otp_cubit.dart';
import '../pages/complete_registration_screen.dart';
import '../pages/forgot_password_screen.dart';
import '../pages/login_screen.dart';
import '../pages/phone_otp_screen.dart';
import '../pages/phone_sign_in_screen.dart';
import '../pages/register_screen.dart';
import '../pages/reset_password_screen.dart';
import '../pages/verify_email_screen.dart';
import '../pages/welcome_screen.dart';

part 'router.g.dart';

const String _welcomeScope = 'WelcomeScope';
const String _registerScope = 'RegisterScope';
const String _verifyEmailScope = 'VerifyEmailScope';
const String _loginScope = 'LoginScope';
const String _phoneSignInScope = 'PhoneSignInScope';
const String _phoneOtpScope = 'PhoneOtpScope';
const String _completeRegistrationScope = 'CompleteRegistrationScope';
const String _forgotPasswordScope = 'ForgotPasswordScope';
const String _resetPasswordScope = 'ResetPasswordScope';

Widget _scoped({
  required String scopeName,
  required List<FeatureRegistration> registrations,
  required List<BlocProvider<dynamic>> providers,
  required Widget child,
}) {
  return FeatureScope(
    scopeName: scopeName,
    registrations: registrations,
    child: MultiBlocProvider(providers: providers, child: child),
  );
}

@TypedGoRoute<WelcomeRoute>(path: AppRoutes.welcome, name: AppRoutes.welcome)
class WelcomeRoute extends GoRouteData with $WelcomeRoute {
  const WelcomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _welcomeScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerVisitorState,
        registerSocialSignIn,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GuestModeCubit>(
          create: (_) => ServiceLocator.instance<GuestModeCubit>(),
        ),
        BlocProvider<SocialSignInCubit>(
          create: (_) => ServiceLocator.instance<SocialSignInCubit>(),
        ),
      ],
      child: const WelcomeScreen(),
    );
  }
}

@TypedGoRoute<RegisterRoute>(path: AppRoutes.register, name: AppRoutes.register)
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _registerScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerRegister,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RegisterCubit>(
          create: (_) => ServiceLocator.instance<RegisterCubit>(),
        ),
      ],
      child: const RegisterScreen(),
    );
  }
}

@TypedGoRoute<VerifyEmailRoute>(
  path: AppRoutes.verifyEmail,
  name: AppRoutes.verifyEmail,
)
class VerifyEmailRoute extends GoRouteData with $VerifyEmailRoute {
  const VerifyEmailRoute({
    required this.email,
    this.resendAvailableInSeconds = 0,
  });

  final String email;
  final int resendAvailableInSeconds;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _verifyEmailScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerVerifyEmail,
        registerOtpCooldown,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyEmailCubit>(
          create: (_) => ServiceLocator.instance<VerifyEmailCubit>(),
        ),
        BlocProvider<RequestEmailOtpCubit>(
          create: (_) => ServiceLocator.instance<RequestEmailOtpCubit>(),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) => ServiceLocator.instance<OtpCooldownCubit>(),
        ),
      ],
      child: VerifyEmailScreen(
        email: email,
        resendAvailableInSeconds: resendAvailableInSeconds,
      ),
    );
  }
}

@TypedGoRoute<LoginRoute>(path: AppRoutes.login, name: AppRoutes.login)
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _loginScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerLogin,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<LoginCubit>(
          create: (_) => ServiceLocator.instance<LoginCubit>(),
        ),
      ],
      child: const LoginScreen(),
    );
  }
}

@TypedGoRoute<PhoneSignInRoute>(
  path: AppRoutes.phoneSignIn,
  name: AppRoutes.phoneSignIn,
)
class PhoneSignInRoute extends GoRouteData with $PhoneSignInRoute {
  const PhoneSignInRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _phoneSignInScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerPhoneSignIn,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => ServiceLocator.instance<RequestPhoneOtpCubit>(),
        ),
      ],
      child: const PhoneSignInScreen(),
    );
  }
}

@TypedGoRoute<PhoneOtpRoute>(path: AppRoutes.phoneOtp, name: AppRoutes.phoneOtp)
class PhoneOtpRoute extends GoRouteData with $PhoneOtpRoute {
  const PhoneOtpRoute({
    required this.dialingCode,
    required this.phone,
    this.resendAvailableInSeconds = 0,
    this.purpose = 'phone_sign_in',
  });

  final String dialingCode;
  final String phone;
  final int resendAvailableInSeconds;
  final String purpose;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _phoneOtpScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerPhoneSignIn,
        registerOtpCooldown,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<VerifyPhoneOtpCubit>(
          create: (_) => ServiceLocator.instance<VerifyPhoneOtpCubit>(),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => ServiceLocator.instance<RequestPhoneOtpCubit>(),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) => ServiceLocator.instance<OtpCooldownCubit>(),
        ),
      ],
      child: PhoneOtpScreen(
        dialingCode: dialingCode,
        phone: phone,
        resendAvailableInSeconds: resendAvailableInSeconds,
        purpose: OtpPurpose.fromWireName(purpose),
      ),
    );
  }
}

@TypedGoRoute<CompleteRegistrationRoute>(
  path: AppRoutes.completeRegistration,
  name: AppRoutes.completeRegistration,
)
class CompleteRegistrationRoute extends GoRouteData
    with $CompleteRegistrationRoute {
  const CompleteRegistrationRoute({required this.$extra});

  final RegistrationDraft $extra;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _completeRegistrationScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerCompleteRegistration,
        registerPhoneSignIn,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<CompleteRegistrationCubit>(
          create: (_) => ServiceLocator.instance<CompleteRegistrationCubit>(),
        ),
        BlocProvider<RequestPhoneOtpCubit>(
          create: (_) => ServiceLocator.instance<RequestPhoneOtpCubit>(),
        ),
      ],
      child: CompleteRegistrationScreen(draft: $extra),
    );
  }
}

@TypedGoRoute<ForgotPasswordRoute>(
  path: AppRoutes.forgotPassword,
  name: AppRoutes.forgotPassword,
)
class ForgotPasswordRoute extends GoRouteData with $ForgotPasswordRoute {
  const ForgotPasswordRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _forgotPasswordScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerPasswordRecovery,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<RequestPasswordResetCubit>(
          create: (_) => ServiceLocator.instance<RequestPasswordResetCubit>(),
        ),
      ],
      child: const ForgotPasswordScreen(),
    );
  }
}

@TypedGoRoute<ResetPasswordRoute>(
  path: AppRoutes.resetPassword,
  name: AppRoutes.resetPassword,
)
class ResetPasswordRoute extends GoRouteData with $ResetPasswordRoute {
  const ResetPasswordRoute({
    required this.email,
    this.resendAvailableInSeconds = 0,
  });

  final String email;
  final int resendAvailableInSeconds;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _scoped(
      scopeName: _resetPasswordScope,
      registrations: const <FeatureRegistration>[
        registerAuthDataLayer,
        registerPasswordRecovery,
        registerOtpCooldown,
      ],
      providers: <BlocProvider<dynamic>>[
        BlocProvider<ResetPasswordCubit>(
          create: (_) => ServiceLocator.instance<ResetPasswordCubit>(),
        ),
        BlocProvider<OtpCooldownCubit>(
          create: (_) => ServiceLocator.instance<OtpCooldownCubit>(),
        ),
      ],
      child: ResetPasswordScreen(
        email: email,
        resendAvailableInSeconds: resendAvailableInSeconds,
      ),
    );
  }
}
