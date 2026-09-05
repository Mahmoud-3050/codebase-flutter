import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/dio_http_adapter.dart';
import 'package:codebase/core/utils/enums.dart';

import 'helpers/api_test_doubles.dart';

void main() {
  tearDown(() {
    AppFlavor.activate(AppFlavor.dev);
    resetDebugTrustBadCertificates();
  });

  test('does not trust invalid certificates without the explicit flag', () {
    AppFlavor.activate(AppFlavor.dev);
    final Dio client = Dio();
    applyHttpAdapter(client);

    final IOHttpClientAdapter adapter =
        client.httpClientAdapter as IOHttpClientAdapter;
    expect(adapter.createHttpClient, isNull);
  });

  test('trusts invalid certificates only when the debug flag is on', () {
    AppFlavor.activate(AppFlavor.dev);
    debugTrustBadCertificates(enabled: true);
    final Dio client = Dio();
    applyHttpAdapter(client);

    final IOHttpClientAdapter adapter =
        client.httpClientAdapter as IOHttpClientAdapter;
    expect(adapter.createHttpClient, isNotNull);
    expect(adapter.createHttpClient!(), isNotNull);
  });

  test('leaves the default adapter for live even with the flag on', () {
    AppFlavor.activate(AppFlavor.live);
    debugTrustBadCertificates(enabled: true);
    final Dio client = Dio();
    applyHttpAdapter(client);

    final IOHttpClientAdapter adapter =
        client.httpClientAdapter as IOHttpClientAdapter;
    expect(adapter.createHttpClient, isNull);
  });

  test('skips adapters that are not dart:io HTTP adapters', () {
    AppFlavor.activate(AppFlavor.dev);
    debugTrustBadCertificates(enabled: true);
    final Dio client = Dio()..httpClientAdapter = ScriptedAdapter();

    expect(() => applyHttpAdapter(client), returnsNormally);
  });
}
