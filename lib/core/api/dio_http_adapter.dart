import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

void applyTrustingHttpAdapter(Dio client) {
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
