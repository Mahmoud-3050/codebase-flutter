import '../utils/enums.dart';

abstract class ApiConstants {
  static const String live = 'https://live-mob-sa.co/v1/api';
  static const String dev = 'https://stage.back-mob-sa.co/v1/api';
  static String get baseUrl => switch (AppFlavor.current) {
    .live => live,
    .dev => dev,
  };

  // Auth
  static const String loginPath = '/auth/login';
  static const String registerPath = '/auth/register';
  static const String forgotPasswordPath = '/auth/forgot-password';
  static const String resetPasswordPath = '/auth/reset-password';
  static const String verifyEmailPath = '/auth/verify-email';
  static const String verifyPhoneNumberPath = '/auth/verify-phone-number';
  static const String refreshTokenPath = '/common/refresh-token';
}
