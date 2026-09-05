import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/debug_api_logger.dart';
import 'package:codebase/core/api/dio_consumer.dart';
import 'package:codebase/core/api/redirect_interceptor.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';

import 'helpers/api_test_doubles.dart';

void main() {
  late Dio dio;
  late ScriptedAdapter adapter;
  late DioConsumerImpl consumer;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    adapter = ScriptedAdapter();
    dio.httpClientAdapter = adapter;
    consumer = DioConsumerImpl(
      client: dio,
      apiInterceptor: const Interceptor(),
    );
    dio.httpClientAdapter = adapter;
  });

  test('get, post, put, patch, and delete forward JSON bodies', () async {
    adapter.handler = (RequestOptions options) {
      expect(
        options.method,
        isIn(<String>['GET', 'POST', 'PUT', 'PATCH', 'DELETE']),
      );
      if (options.method != 'GET') {
        expect(options.data, <String, dynamic>{'id': 1});
      }
      return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
    };

    await consumer.get('/a', queryParameters: <String, dynamic>{'q': '1'});
    await consumer.post('/a', body: <String, dynamic>{'id': 1});
    await consumer.put('/a', body: <String, dynamic>{'id': 1});
    await consumer.patch('/a', body: <String, dynamic>{'id': 1});
    await consumer.delete('/a', body: <String, dynamic>{'id': 1});
    expect(adapter.calls, 5);
  });

  test('sends FormData with a multipart content type', () async {
    adapter.handler = (RequestOptions options) {
      expect(options.data, isA<FormData>());
      expect(options.contentType, contains('multipart/form-data'));
      return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
    };

    FormData form() => FormData.fromMap(<String, dynamic>{'file': 'x'});
    await consumer.post('/upload', formData: form());
    await consumer.put('/upload', formData: form());
    await consumer.patch('/upload', formData: form());
    await consumer.delete('/upload', formData: form());
    expect(adapter.calls, 4);
  });

  test('returns null data for 204 responses', () async {
    adapter.handler = (_) => emptyBody(StatusCode.noContent);

    expect(await consumer.get('/empty'), isNull);
  });

  test('does not add the same interceptor twice', () {
    const Interceptor interceptor = Interceptor();
    final Dio client = Dio();
    final DioConsumerImpl first = DioConsumerImpl(
      client: client,
      apiInterceptor: interceptor,
    );
    final DioConsumerImpl second = DioConsumerImpl(
      client: client,
      apiInterceptor: interceptor,
    );

    expect(identical(first.client, second.client), isTrue);
    expect(
      client.interceptors
          .where((Interceptor item) => identical(item, interceptor))
          .length,
      1,
    );
    expect(client.interceptors.whereType<DebugApiLogger>().length, 1);
  });

  test('uses named timeouts that keep a long receive budget for uploads', () {
    expect(dio.options.connectTimeout, ApiTimeouts.connect);
    expect(dio.options.sendTimeout, ApiTimeouts.send);
    expect(dio.options.receiveTimeout, ApiTimeouts.receive);
    expect(dio.options.followRedirects, isFalse);
    expect(dio.interceptors.whereType<SafeRedirectInterceptor>(), isNotEmpty);
  });

  test('maps a cancelled CancelToken to RequestCancelledException', () async {
    final CancelToken cancelToken = CancelToken()..cancel('stop');

    await expectLater(
      consumer.get('/x', cancelToken: cancelToken),
      throwsA(isA<RequestCancelledException>()),
    );
  });

  test('maps unwrapped DioException types through the mapper', () async {
    adapter.handler = (RequestOptions options) {
      throw DioException(requestOptions: options, type: .cancel);
    };

    await expectLater(
      consumer.get('/x'),
      throwsA(isA<RequestCancelledException>()),
    );
  });

  test('maps SocketException to InternetConnectionException', () async {
    adapter.handler = (_) => throw const SocketException('offline');

    await expectLater(
      consumer.get('/x'),
      throwsA(isA<InternetConnectionException>()),
    );
  });

  test('uses the flavor base URL', () {
    expect(dio.options.baseUrl, ApiConstants.baseUrl);
    expect(dio.options.headers[ApiHeaders.accept], 'application/json');
  });
}
