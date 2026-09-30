// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $welcomeRoute,
  $registerRoute,
  $verifyEmailRoute,
  $loginRoute,
  $phoneSignInRoute,
  $phoneOtpRoute,
  $completeRegistrationRoute,
  $forgotPasswordRoute,
  $resetPasswordRoute,
];

RouteBase get $welcomeRoute => GoRouteData.$route(
  path: '/welcome',
  name: '/welcome',
  hasOverriddenOnExit: false,
  factory: $WelcomeRoute._fromState,
);

mixin $WelcomeRoute on GoRouteData {
  static WelcomeRoute _fromState(GoRouterState state) => const WelcomeRoute();

  @override
  String get location => GoRouteData.$location('/welcome');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $registerRoute => GoRouteData.$route(
  path: '/register',
  name: '/register',
  hasOverriddenOnExit: false,
  factory: $RegisterRoute._fromState,
);

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => const RegisterRoute();

  @override
  String get location => GoRouteData.$location('/register');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $verifyEmailRoute => GoRouteData.$route(
  path: '/verify-email',
  name: '/verify-email',
  hasOverriddenOnExit: false,
  factory: $VerifyEmailRoute._fromState,
);

mixin $VerifyEmailRoute on GoRouteData {
  static VerifyEmailRoute _fromState(GoRouterState state) => VerifyEmailRoute(
    email: state.uri.queryParameters['email']!,
    resendAvailableInSeconds:
        _$convertMapValue(
          'resend-available-in-seconds',
          state.uri.queryParameters,
          int.parse,
        ) ??
        0,
  );

  VerifyEmailRoute get _self => this as VerifyEmailRoute;

  @override
  String get location => GoRouteData.$location(
    '/verify-email',
    queryParams: {
      'email': _self.email,
      if (_self.resendAvailableInSeconds != 0)
        'resend-available-in-seconds': _self.resendAvailableInSeconds
            .toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

T? _$convertMapValue<T>(
  String key,
  Map<String, String> map,
  T? Function(String) converter,
) {
  final value = map[key];
  return value == null ? null : converter(value);
}

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',
  name: '/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $phoneSignInRoute => GoRouteData.$route(
  path: '/phone-sign-in',
  name: '/phone-sign-in',
  hasOverriddenOnExit: false,
  factory: $PhoneSignInRoute._fromState,
);

mixin $PhoneSignInRoute on GoRouteData {
  static PhoneSignInRoute _fromState(GoRouterState state) =>
      const PhoneSignInRoute();

  @override
  String get location => GoRouteData.$location('/phone-sign-in');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $phoneOtpRoute => GoRouteData.$route(
  path: '/phone-otp',
  name: '/phone-otp',
  hasOverriddenOnExit: false,
  factory: $PhoneOtpRoute._fromState,
);

mixin $PhoneOtpRoute on GoRouteData {
  static PhoneOtpRoute _fromState(GoRouterState state) => PhoneOtpRoute(
    dialingCode: state.uri.queryParameters['dialing-code']!,
    phone: state.uri.queryParameters['phone']!,
    resendAvailableInSeconds:
        _$convertMapValue(
          'resend-available-in-seconds',
          state.uri.queryParameters,
          int.parse,
        ) ??
        0,
    purpose: state.uri.queryParameters['purpose'] ?? 'phone_sign_in',
  );

  PhoneOtpRoute get _self => this as PhoneOtpRoute;

  @override
  String get location => GoRouteData.$location(
    '/phone-otp',
    queryParams: {
      'dialing-code': _self.dialingCode,
      'phone': _self.phone,
      if (_self.resendAvailableInSeconds != 0)
        'resend-available-in-seconds': _self.resendAvailableInSeconds
            .toString(),
      if (_self.purpose != 'phone_sign_in') 'purpose': _self.purpose,
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $completeRegistrationRoute => GoRouteData.$route(
  path: '/complete-registration',
  name: '/complete-registration',
  hasOverriddenOnExit: false,
  factory: $CompleteRegistrationRoute._fromState,
);

mixin $CompleteRegistrationRoute on GoRouteData {
  static CompleteRegistrationRoute _fromState(GoRouterState state) =>
      CompleteRegistrationRoute($extra: state.extra as RegistrationDraft);

  CompleteRegistrationRoute get _self => this as CompleteRegistrationRoute;

  @override
  String get location => GoRouteData.$location('/complete-registration');

  @override
  void go(BuildContext context) => context.go(location, extra: _self.$extra);

  @override
  Future<T?> push<T>(BuildContext context) =>
      context.push<T>(location, extra: _self.$extra);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location, extra: _self.$extra);

  @override
  void replace(BuildContext context) =>
      context.replace(location, extra: _self.$extra);
}

RouteBase get $forgotPasswordRoute => GoRouteData.$route(
  path: '/forgot-password',
  name: '/forgot-password',
  hasOverriddenOnExit: false,
  factory: $ForgotPasswordRoute._fromState,
);

mixin $ForgotPasswordRoute on GoRouteData {
  static ForgotPasswordRoute _fromState(GoRouterState state) =>
      const ForgotPasswordRoute();

  @override
  String get location => GoRouteData.$location('/forgot-password');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $resetPasswordRoute => GoRouteData.$route(
  path: '/reset-password',
  name: '/reset-password',
  hasOverriddenOnExit: false,
  factory: $ResetPasswordRoute._fromState,
);

mixin $ResetPasswordRoute on GoRouteData {
  static ResetPasswordRoute _fromState(GoRouterState state) =>
      ResetPasswordRoute(
        email: state.uri.queryParameters['email']!,
        resendAvailableInSeconds:
            _$convertMapValue(
              'resend-available-in-seconds',
              state.uri.queryParameters,
              int.parse,
            ) ??
            0,
      );

  ResetPasswordRoute get _self => this as ResetPasswordRoute;

  @override
  String get location => GoRouteData.$location(
    '/reset-password',
    queryParams: {
      'email': _self.email,
      if (_self.resendAvailableInSeconds != 0)
        'resend-available-in-seconds': _self.resendAvailableInSeconds
            .toString(),
    },
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
