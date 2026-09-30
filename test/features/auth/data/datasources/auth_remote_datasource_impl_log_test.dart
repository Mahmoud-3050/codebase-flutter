import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/debug_api_logger.dart';
import 'package:codebase/core/api/status_code.dart';

import '../../../../core/api/helpers/api_test_doubles.dart';

void main() {
  test(
    'FR-045 SC-010 auth operations omit password and OTP from logs',
    () async {
      final List<String> logs = <String>[];
      final Dio dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
      final ScriptedAdapter adapter = ScriptedAdapter();
      dio.httpClientAdapter = adapter;
      dio.interceptors.add(
        DebugApiLogger(
          logPrint: (Object object) => logs.add(object.toString()),
        ),
      );
      adapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'status': 'success',
        'code': '123456',
      });

      for (final String path in ApiConstants.publicAuthPaths) {
        logs.clear();
        await dio.post<dynamic>(
          path,
          data: <String, dynamic>{'password': 'super-secret', 'code': '123456'},
        );
        final String output = logs.join('\n');
        expect(output, contains('body omitted'), reason: path);
        expect(output, isNot(contains('super-secret')), reason: path);
        expect(output, isNot(contains('123456')), reason: path);
      }
    },
  );
}
