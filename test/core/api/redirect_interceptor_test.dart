import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/redirect_interceptor.dart';
import 'package:codebase/core/api/status_code.dart';

import 'helpers/api_test_doubles.dart';

void main() {
  late Dio dio;
  late ScriptedAdapter adapter;

  setUp(() {
    dio = Dio(
      BaseOptions(baseUrl: 'https://api.example.test', followRedirects: false),
    );
    adapter = ScriptedAdapter();
    dio.httpClientAdapter = adapter;
    addRedirectInterceptor(dio);
  });

  test('follows a same-origin redirect and keeps Authorization', () async {
    adapter.handler = (RequestOptions options) {
      if (options.uri.path == '/from') {
        expect(options.headers[ApiHeaders.authorization], 'Bearer secret');
        return redirectBody(StatusCode.found, '/to');
      }
      expect(options.uri.origin, 'https://api.example.test');
      expect(options.headers[ApiHeaders.authorization], 'Bearer secret');
      return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
    };

    final Response<dynamic> response = await dio.get<dynamic>(
      '/from',
      options: Options(
        headers: <String, dynamic>{ApiHeaders.authorization: 'Bearer secret'},
      ),
    );

    expect(response.data['ok'], isTrue);
    expect(adapter.calls, 2);
  });

  test('strips Authorization on a cross-origin redirect', () async {
    adapter.handler = (RequestOptions options) {
      if (options.uri.host == 'api.example.test') {
        expect(options.headers[ApiHeaders.authorization], 'Bearer secret');
        return redirectBody(StatusCode.found, 'https://evil.example.test/leak');
      }
      expect(options.uri.host, 'evil.example.test');
      expect(options.headers.containsKey(ApiHeaders.authorization), isFalse);
      return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
    };

    final Response<dynamic> response = await dio.get<dynamic>(
      '/from',
      options: Options(
        headers: <String, dynamic>{ApiHeaders.authorization: 'Bearer secret'},
      ),
    );

    expect(response.data['ok'], isTrue);
    expect(adapter.calls, 2);
  });

  test('converts 303 to GET and drops the body', () async {
    adapter.handler = (RequestOptions options) {
      if (options.uri.path == '/from') {
        expect(options.method, 'POST');
        expect(options.data, isNotNull);
        return redirectBody(StatusCode.seeOther, '/to');
      }
      expect(options.method, 'GET');
      expect(options.data, isNull);
      return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
    };

    final Response<dynamic> response = await dio.post<dynamic>(
      '/from',
      data: <String, dynamic>{'secret': 'yes'},
    );

    expect(response.data['ok'], isTrue);
    expect(adapter.calls, 2);
  });

  test('does not replay a POST body on a cross-origin 307', () async {
    adapter.handler = (RequestOptions options) {
      expect(options.uri.host, 'api.example.test');
      expect(options.data, <String, dynamic>{'password': 'secret'});
      return redirectBody(
        StatusCode.temporaryRedirect,
        'https://evil.example.test/steal',
      );
    };

    await expectLater(
      dio.post<dynamic>(
        '/login',
        data: <String, dynamic>{'password': 'secret'},
      ),
      throwsA(
        isA<DioException>().having(
          (DioException error) => error.response?.statusCode,
          'statusCode',
          StatusCode.temporaryRedirect,
        ),
      ),
    );
    expect(adapter.calls, 1);
  });

  test('follows a same-origin 307 POST and keeps the body', () async {
    adapter.handler = (RequestOptions options) {
      if (options.uri.path == '/from') {
        expect(options.method, 'POST');
        expect(options.data, <String, dynamic>{'password': 'secret'});
        return redirectBody(StatusCode.temporaryRedirect, '/to');
      }
      expect(options.uri.origin, 'https://api.example.test');
      expect(options.method, 'POST');
      expect(options.data, <String, dynamic>{'password': 'secret'});
      return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
    };

    final Response<dynamic> response = await dio.post<dynamic>(
      '/from',
      data: <String, dynamic>{'password': 'secret'},
    );

    expect(response.data['ok'], isTrue);
    expect(adapter.calls, 2);
  });

  test('stops after the maximum number of redirects', () async {
    adapter.handler = (_) => redirectBody(StatusCode.found, '/loop');

    await expectLater(
      dio.get<dynamic>('/loop'),
      throwsA(
        isA<DioException>().having(
          (DioException error) => error.response?.statusCode,
          'statusCode',
          StatusCode.found,
        ),
      ),
    );
    expect(adapter.calls, SafeRedirectInterceptor.maxRedirects + 1);
  });
}
