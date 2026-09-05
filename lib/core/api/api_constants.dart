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

  /// Login/register/verify must not send a leftover access token or trigger refresh.
  static const List<String> publicAuthPaths = <String>[
    loginPath,
    registerPath,
    forgotPasswordPath,
    resetPasswordPath,
    verifyEmailPath,
    verifyPhoneNumberPath,
  ];

  static bool matchesPath(String requestPath, String apiPath) {
    final String normalized = Uri.parse(requestPath).path;
    return normalized == apiPath || normalized.endsWith(apiPath);
  }

  static bool isPublicAuthPath(String requestPath) {
    return publicAuthPaths.any(
      (String apiPath) => matchesPath(requestPath, apiPath),
    );
  }

  /// Whether debug logs must omit the body (passwords, tokens).
  static bool shouldOmitLogBody(String requestPath) {
    return isPublicAuthPath(requestPath) ||
        matchesPath(requestPath, refreshTokenPath);
  }
}

abstract final class ApiTimeouts {
  static const Duration connect = Duration(seconds: 30);
  static const Duration send = Duration(seconds: 120);
  static const Duration receive = Duration(seconds: 360);

  static const Duration refreshConnect = Duration(seconds: 30);
  static const Duration refreshSend = Duration(seconds: 30);
  static const Duration refreshReceive = Duration(seconds: 30);
}

abstract final class ApiHeaders {
  static const String accept = 'accept';
  static const String acceptLanguage = 'accept-language';
  static const String authorization = 'authorization';
  static const String location = 'location';
}
