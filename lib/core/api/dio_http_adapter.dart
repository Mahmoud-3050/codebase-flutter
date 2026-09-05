import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../utils/enums.dart';

/// Compile-time opt-in for self-signed/invalid TLS in debug + dev only.
///
/// Pass `--dart-define=TRUST_BAD_CERTIFICATES=true` (see the "dev (trust bad
/// certs)" launch config). Profile, release, and live debug always validate.
const bool kTrustBadCertificates = bool.fromEnvironment(
  'TRUST_BAD_CERTIFICATES',
);

bool? _trustBadCertificatesOverride;

/// Test-only override for [kTrustBadCertificates].
@visibleForTesting
void debugTrustBadCertificates({required bool enabled}) {
  _trustBadCertificatesOverride = enabled;
}

@visibleForTesting
void resetDebugTrustBadCertificates() {
  _trustBadCertificatesOverride = null;
}

/// Configures Dio's dart:io adapter for the current build.
void applyHttpAdapter(Dio client) {
  if (!_shouldTrustBadCertificates) {
    return;
  }
  _applyTrustingHttpAdapter(client);
}

bool get _shouldTrustBadCertificates {
  if (!kDebugMode || !AppFlavor.current.isDev) {
    return false;
  }
  return _trustBadCertificatesOverride ?? kTrustBadCertificates;
}

void _applyTrustingHttpAdapter(Dio client) {
  final HttpClientAdapter adapter = client.httpClientAdapter;
  if (adapter is! IOHttpClientAdapter) {
    return;
  }
  adapter.createHttpClient = () {
    final HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return httpClient;
  };
}
