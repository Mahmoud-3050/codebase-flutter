import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

/// Configures Dio's dart:io adapter for the current build.
///
/// Debug: accept invalid/self-signed TLS certificates (local / staging).
/// Profile & release: leave Dio's default client (certificates are validated).
void applyHttpAdapter(Dio client) {
  if (kDebugMode) {
    _applyTrustingHttpAdapter(client);
  }
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
