import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/debug_api_logger.dart';
import 'package:codebase/core/api/status_code.dart';

import 'helpers/api_test_doubles.dart';

void main() {
  late Dio dio;
  late ScriptedAdapter adapter;
  late List<String> logs;

  setUp(() {
    logs = <String>[];
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    adapter = ScriptedAdapter();
    dio.httpClientAdapter = adapter;
    dio.interceptors.add(
      DebugApiLogger(logPrint: (Object object) => logs.add(object.toString())),
    );
  });

  test('omits login request and response bodies', () async {
    adapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
      'access_token': 'secret-token',
    });

    await dio.post<dynamic>(
      ApiConstants.loginPath,
      data: <String, dynamic>{'password': 'super-secret'},
    );

    final String output = logs.join('\n');
    expect(output, contains('body omitted'));
    expect(output, isNot(contains('super-secret')));
    expect(output, isNot(contains('secret-token')));
  });

  test('omits refresh response bodies', () async {
    adapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
      'data': <String, dynamic>{'access_token': 'rotated-token'},
    });

    await dio.post<dynamic>(ApiConstants.refreshTokenPath);

    final String output = logs.join('\n');
    expect(output, contains('body omitted'));
    expect(output, isNot(contains('rotated-token')));
  });

  test('logs bodies on non-auth paths', () async {
    adapter.handler = (_) =>
        jsonBody(StatusCode.ok, <String, dynamic>{'name': 'Ada'});

    await dio.post<dynamic>(
      '/student/profile/edit',
      data: <String, dynamic>{'name': 'Ada'},
    );

    final String output = logs.join('\n');
    expect(output, contains('Ada'));
    expect(output, isNot(contains('body omitted')));
  });
}
