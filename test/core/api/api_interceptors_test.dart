import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/api_interceptors.dart';
import 'package:codebase/core/api/dio_consumer.dart';
import 'package:codebase/core/api/refresh_token_helper.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';
import 'package:codebase/core/services/local_storage/access_token_storage.dart';

void main() {
  late FakeAccessTokenStorage storage;
  late Dio mainDio;
  late Dio refreshDio;
  late _ScriptedAdapter mainAdapter;
  late _ScriptedAdapter refreshAdapter;
  late DioConsumerImpl consumer;

  setUp(() {
    storage = FakeAccessTokenStorage();
    mainDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    mainAdapter = _ScriptedAdapter();
    refreshAdapter = _ScriptedAdapter();
    mainDio.httpClientAdapter = mainAdapter;
    refreshDio.httpClientAdapter = refreshAdapter;

    final RefreshTokenHelper refreshTokenHelper = RefreshTokenHelper(
      tokenStorage: storage,
      refreshClient: refreshDio,
      languageCode: () => 'ar',
    );
    final ApiInterceptors interceptor = ApiInterceptors(
      retryClient: mainDio,
      refreshTokenHelper: refreshTokenHelper,
      languageCode: () => 'ar',
      noInternetMessage: () => 'No internet',
    );
    consumer = DioConsumerImpl(
      client: mainDio,
      apiInterceptor: interceptor,
    );
    mainDio.httpClientAdapter = mainAdapter;
  });

  group('request headers', () {
    test('attaches Bearer token and Accept-Language on each request', () async {
      storage.token = 'abc123';
      mainAdapter.handler = (RequestOptions options) {
        expect(
            options.headers[HttpHeaders.authorizationHeader], 'Bearer abc123');
        expect(options.headers[HttpHeaders.acceptLanguageHeader], 'ar');
        expect(options.headers[HttpHeaders.acceptHeader], 'application/json');
        return _jsonBody(StatusCode.ok, <String, dynamic>{'status': 'success'});
      };

      final dynamic data = await consumer.get('/profile');
      expect(data['status'], 'success');
    });

    test('omits Authorization when no access token is stored', () async {
      mainAdapter.handler = (RequestOptions options) {
        expect(options.headers.containsKey(HttpHeaders.authorizationHeader),
            isFalse);
        return _jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
      };

      await consumer.get('/public');
    });
  });

  group('error mapping', () {
    test('unwraps UnauthorizedException for 401 on public requests', () async {
      mainAdapter.handler = (_) => _jsonBody(
            StatusCode.unauthorized,
            <String, dynamic>{'message': 'Invalid credentials'},
          );

      await expectLater(
        consumer.post('/common/login', body: <String, dynamic>{}),
        throwsA(
          isA<UnauthorizedException>().having(
            (UnauthorizedException e) => e.message,
            'message',
            'Invalid credentials',
          ),
        ),
      );
      expect(refreshAdapter.calls, 0);
    });

    test('unwraps ServerException for 500', () async {
      mainAdapter.handler = (_) => _jsonBody(
            StatusCode.internalServerError,
            <String, dynamic>{'message': 'Boom'},
          );

      await expectLater(
        consumer.get('/profile'),
        throwsA(
          isA<ServerException>()
              .having((ServerException e) => e.message, 'message', 'Boom')
              .having(
                (ServerException e) => e.statusCode,
                'statusCode',
                StatusCode.internalServerError,
              ),
        ),
      );
    });
  });

  group('refresh access token', () {
    test('refreshes once then retries the original request', () async {
      storage.token = 'old-access';
      int protectedCalls = 0;

      mainAdapter.handler = (RequestOptions options) {
        protectedCalls++;
        if (protectedCalls == 1) {
          expect(options.headers[HttpHeaders.authorizationHeader],
              'Bearer old-access');
          return _jsonBody(
            StatusCode.unauthorized,
            <String, dynamic>{'message': 'expired'},
          );
        }
        expect(options.headers[HttpHeaders.authorizationHeader],
            'Bearer new-access');
        return _jsonBody(StatusCode.ok, <String, dynamic>{'status': 'success'});
      };
      refreshAdapter.handler = (RequestOptions options) {
        expect(options.path, ApiConstants.refreshTokenPath);
        expect(options.headers[HttpHeaders.authorizationHeader],
            'Bearer old-access');
        return _jsonBody(
          StatusCode.ok,
          <String, dynamic>{
            'status': 'success',
            'data': <String, dynamic>{
              'access_token': 'new-access',
            },
          },
        );
      };

      final dynamic data = await consumer.get('/student/profile/edit');

      expect(data['status'], 'success');
      expect(protectedCalls, 2);
      expect(refreshAdapter.calls, 1);
      expect(storage.token, 'new-access');
    });

    test('shares one refresh across concurrent 401s', () async {
      storage.token = 'old-access';

      mainAdapter.handler = (RequestOptions options) {
        if (options.headers[HttpHeaders.authorizationHeader] ==
            'Bearer old-access') {
          return _jsonBody(
            StatusCode.unauthorized,
            <String, dynamic>{'message': 'expired'},
          );
        }
        return _jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
      };
      refreshAdapter.handler = (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return _jsonBody(
          StatusCode.ok,
          <String, dynamic>{
            'data': <String, dynamic>{'accessToken': 'new-access'},
          },
        );
      };

      await Future.wait<dynamic>(<Future<dynamic>>[
        consumer.get('/one'),
        consumer.get('/two'),
      ]);

      expect(refreshAdapter.calls, 1);
      expect(storage.token, 'new-access');
    });

    test('clears the access token when refresh fails', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => _jsonBody(
            StatusCode.unauthorized,
            <String, dynamic>{'message': 'expired'},
          );
      refreshAdapter.handler = (_) => _jsonBody(
            StatusCode.unauthorized,
            <String, dynamic>{'message': 'invalid refresh'},
          );

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(storage.token, isNull);
    });
  });
}

class FakeAccessTokenStorage implements AccessTokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> save(String value) async => token = value;

  @override
  Future<void> remove() async => token = null;
}

class _ScriptedAdapter implements HttpClientAdapter {
  FutureOr<ResponseBody> Function(RequestOptions options)? handler;
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    final FutureOr<ResponseBody> Function(RequestOptions options)? current =
        handler;
    if (current == null) {
      throw StateError('No adapter handler for ${options.path}');
    }
    return current(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(int statusCode, Map<String, dynamic> data) {
  return .fromString(
    jsonEncode(data),
    statusCode,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}
