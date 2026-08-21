import 'package:flutter/foundation.dart';

abstract class ApiConstants {
  static const String live = 'https://live-mob-sa.co/v1/api';
  static const String staging = 'https://stage.back-mob-sa.co/v1/api';
  static String get baseUrl => live;

  /// Self-signed certs are only allowed in debug builds pointed at staging.
  static bool get allowInsecureCertificates => kDebugMode && baseUrl == staging;
}
