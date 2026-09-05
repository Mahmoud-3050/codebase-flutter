import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/api_interceptors.dart';
import 'package:codebase/core/api/dio_consumer.dart';
import 'package:codebase/core/api/refresh_token_helper.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';

import 'helpers/api_test_doubles.dart';

void main() {
  late FakeAccessTokenStorage storage;
  late FakeUserTypeStorage userTypeStorage;
  late int sessionExpiredCount;
  late Dio mainDio;
  late Dio refreshDio;
  late ScriptedAdapter mainAdapter;
  late ScriptedAdapter refreshAdapter;
  late DioConsumerImpl consumer;

  setUp(() {
    storage = FakeAccessTokenStorage();
    userTypeStorage = FakeUserTypeStorage()..value = 'loggedIn';
    sessionExpiredCount = 0;
    mainDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    refreshDio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    mainAdapter = ScriptedAdapter();
    refreshAdapter = ScriptedAdapter();
    mainDio.httpClientAdapter = mainAdapter;
    refreshDio.httpClientAdapter = refreshAdapter;

    RefreshTokenHelper.instance.init(
      tokenStorage: storage,
      userTypeStorage: userTypeStorage,
      refreshClient: refreshDio,
      languageCode: () => 'ar',
      onSessionExpired: () async {
        sessionExpiredCount++;
      },
    );
    ApiInterceptor.instance.init(
      retryClient: mainDio,
      refreshTokenHelper: .instance,
      getLanguageCode: () => 'ar',
      noInternetMessage: () => 'No internet',
    );
    consumer = DioConsumerImpl(
      client: mainDio,
      apiInterceptor: ApiInterceptor.instance,
    );
    mainDio.httpClientAdapter = mainAdapter;
  });

  tearDown(() {
    RefreshTokenHelper.instance.reset();
    ApiInterceptor.instance.reset();
  });

  group('request headers', () {
    test('attaches Bearer token and Accept-Language on each request', () async {
      storage.token = 'abc123';
      mainAdapter.handler = (RequestOptions options) {
        expect(options.headers[ApiHeaders.authorization], 'Bearer abc123');
        expect(options.headers[ApiHeaders.acceptLanguage], 'ar');
        expect(options.headers[ApiHeaders.accept], 'application/json');
        return jsonBody(StatusCode.ok, <String, dynamic>{'status': 'success'});
      };

      final dynamic data = await consumer.get('/profile');
      expect(data['status'], 'success');
    });

    test('omits Authorization when no access token is stored', () async {
      mainAdapter.handler = (RequestOptions options) {
        expect(options.headers.containsKey(ApiHeaders.authorization), isFalse);
        return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
      };

      await consumer.get('/public');
    });

    test(
      'omits Authorization on public auth paths even when a token is stored',
      () async {
        storage.token = 'abc123';
        mainAdapter.handler = (RequestOptions options) {
          expect(
            options.headers.containsKey(ApiHeaders.authorization),
            isFalse,
          );
          expect(options.headers[ApiHeaders.acceptLanguage], 'ar');
          return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
        };

        await consumer.post(ApiConstants.loginPath, body: <String, dynamic>{});
        expect(refreshAdapter.calls, 0);
      },
    );

    test('does not forward Authorization on a cross-origin redirect', () async {
      storage.token = 'secret';
      mainAdapter.handler = (RequestOptions options) {
        if (options.uri.host == 'evil.example.test') {
          expect(
            options.headers.containsKey(ApiHeaders.authorization),
            isFalse,
          );
          return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
        }
        expect(options.headers[ApiHeaders.authorization], 'Bearer secret');
        return redirectBody(StatusCode.found, 'https://evil.example.test/leak');
      };

      final dynamic data = await consumer.get('/from');
      expect(data['ok'], isTrue);
      expect(mainAdapter.calls, 2);
    });

    test('keeps Authorization on a same-origin redirect', () async {
      storage.token = 'secret';
      mainAdapter.handler = (RequestOptions options) {
        expect(options.headers[ApiHeaders.authorization], 'Bearer secret');
        if (options.uri.path.endsWith('/from')) {
          return redirectBody(StatusCode.found, '/to');
        }
        return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
      };

      final dynamic data = await consumer.get('/from');
      expect(data['ok'], isTrue);
      expect(mainAdapter.calls, 2);
    });
  });

  group('error mapping', () {
    test('unwraps UnauthorizedException for 401 on public requests', () async {
      mainAdapter.handler = (_) => jsonBody(
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
      mainAdapter.handler = (_) => jsonBody(
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

    test('maps onRequest failures through the consumer', () async {
      ApiInterceptor.instance.init(
        retryClient: mainDio,
        refreshTokenHelper: RefreshTokenHelper.instance,
        getLanguageCode: () => throw StateError('language missing'),
        noInternetMessage: () => 'No internet',
      );

      await expectLater(
        consumer.get('/profile'),
        throwsA(isA<ServerException>()),
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
          expect(
            options.headers[ApiHeaders.authorization],
            'Bearer old-access',
          );
          return jsonBody(StatusCode.unauthorized, <String, dynamic>{
            'message': 'expired',
          });
        }
        expect(options.headers[ApiHeaders.authorization], 'Bearer new-access');
        expect(
          options.extra[RefreshTokenHelper.retriedRequestExtraKey],
          isTrue,
        );
        return jsonBody(StatusCode.ok, <String, dynamic>{'status': 'success'});
      };
      refreshAdapter.handler = (RequestOptions options) {
        expect(options.path, ApiConstants.refreshTokenPath);
        expect(options.headers[ApiHeaders.authorization], 'Bearer old-access');
        return jsonBody(StatusCode.ok, <String, dynamic>{
          'status': 'success',
          'data': <String, dynamic>{'access_token': 'new-access'},
        });
      };

      final dynamic data = await consumer.get('/student/profile/edit');

      expect(data['status'], 'success');
      expect(protectedCalls, 2);
      expect(refreshAdapter.calls, 1);
      expect(storage.token, 'new-access');
      expect(sessionExpiredCount, 0);
    });

    test('keeps the old token when refresh save fails', () async {
      storage
        ..token = 'old-access'
        ..saveSucceeds = false;
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'data': <String, dynamic>{'access_token': 'new-access'},
      });

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<CacheException>()),
      );
      expect(storage.token, 'old-access');
      expect(sessionExpiredCount, 0);
      expect(refreshAdapter.calls, 1);
    });

    test('shares one refresh across concurrent 401s', () async {
      storage.token = 'old-access';

      mainAdapter.handler = (RequestOptions options) {
        if (options.headers[ApiHeaders.authorization] == 'Bearer old-access') {
          return jsonBody(StatusCode.unauthorized, <String, dynamic>{
            'message': 'expired',
          });
        }
        return jsonBody(StatusCode.ok, <String, dynamic>{'ok': true});
      };
      refreshAdapter.handler = (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return jsonBody(StatusCode.ok, <String, dynamic>{
          'data': <String, dynamic>{'accessToken': 'new-access'},
        });
      };

      await Future.wait<dynamic>(<Future<dynamic>>[
        consumer.get('/one'),
        consumer.get('/two'),
      ]);

      expect(refreshAdapter.calls, 1);
      expect(storage.token, 'new-access');
    });

    test('clears the access token when refresh fails with HTTP 401', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'invalid refresh'},
      );

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(storage.token, isNull);
      expect(userTypeStorage.value, 'guest');
      expect(sessionExpiredCount, 1);
    });

    test('clears tokens when refresh 200 has no access token', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'status': 'error',
        'message': 'session ended',
      });

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(
          isA<UnauthorizedException>().having(
            (UnauthorizedException e) => e.message,
            'message',
            'session ended',
          ),
        ),
      );
      expect(storage.token, isNull);
      expect(userTypeStorage.value, 'guest');
      expect(sessionExpiredCount, 1);
    });

    test('does not clear tokens when refresh times out', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (RequestOptions options) {
        throw DioException(requestOptions: options, type: .connectionTimeout);
      };

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<InternetConnectionException>()),
      );
      expect(storage.token, 'old-access');
      expect(refreshAdapter.calls, 1);
      expect(sessionExpiredCount, 0);
    });

    test('does not clear tokens when refresh fails with HTTP 500', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(
        StatusCode.internalServerError,
        <String, dynamic>{'message': 'refresh down'},
      );

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(
          isA<ServerException>()
              .having(
                (ServerException e) => e.message,
                'message',
                'refresh down',
              )
              .having(
                (ServerException e) => e.statusCode,
                'statusCode',
                StatusCode.internalServerError,
              ),
        ),
      );
      expect(storage.token, 'old-access');
      expect(refreshAdapter.calls, 1);
      expect(sessionExpiredCount, 0);
    });

    test('does not clear tokens when refresh is rate limited', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(
        StatusCode.tooManyRequests,
        <String, dynamic>{'message': 'Slow down'},
      );

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<TooManyRequestsException>()),
      );
      expect(storage.token, 'old-access');
      expect(sessionExpiredCount, 0);
    });

    test('does not clear tokens when refresh is cancelled', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (RequestOptions options) {
        throw DioException(requestOptions: options, type: .cancel);
      };

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<RequestCancelledException>()),
      );
      expect(storage.token, 'old-access');
      expect(sessionExpiredCount, 0);
    });

    test('clears tokens when refresh fails with HTTP 403', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(
        StatusCode.forbidden,
        <String, dynamic>{'message': 'revoked'},
      );

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(storage.token, isNull);
      expect(userTypeStorage.value, 'guest');
      expect(sessionExpiredCount, 1);
    });

    test('does not refresh a 401 on a public auth path', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (RequestOptions options) {
        expect(options.headers.containsKey(ApiHeaders.authorization), isFalse);
        return jsonBody(StatusCode.unauthorized, <String, dynamic>{
          'message': 'Invalid credentials',
        });
      };

      await expectLater(
        consumer.post(ApiConstants.loginPath, body: <String, dynamic>{}),
        throwsA(
          isA<UnauthorizedException>().having(
            (UnauthorizedException e) => e.message,
            'message',
            'Invalid credentials',
          ),
        ),
      );
      expect(refreshAdapter.calls, 0);
      expect(storage.token, 'old-access');
      expect(sessionExpiredCount, 0);
    });

    test('invalidates the session when retry still returns 401', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (RequestOptions options) {
        return jsonBody(StatusCode.unauthorized, <String, dynamic>{
          'message': 'expired',
        });
      };
      refreshAdapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'data': <String, dynamic>{'access_token': 'new-access'},
      });

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(refreshAdapter.calls, 1);
      expect(storage.token, isNull);
      expect(userTypeStorage.value, 'guest');
      expect(sessionExpiredCount, 1);
    });

    test(
      'does not refresh again after a retry-still-401 session kill',
      () async {
        storage.token = 'old-access';
        mainAdapter.handler = (_) => jsonBody(
          StatusCode.unauthorized,
          <String, dynamic>{'message': 'expired'},
        );
        refreshAdapter.handler = (_) =>
            jsonBody(StatusCode.ok, <String, dynamic>{
              'data': <String, dynamic>{'access_token': 'new-access'},
            });

        await expectLater(
          consumer.get('/student/profile/edit'),
          throwsA(isA<UnauthorizedException>()),
        );
        expect(refreshAdapter.calls, 1);

        await expectLater(
          consumer.get('/student/profile/edit'),
          throwsA(isA<UnauthorizedException>()),
        );
        expect(refreshAdapter.calls, 1);
        expect(storage.token, isNull);
      },
    );

    test('notifies session expiry once for concurrent refresh 401s', () async {
      storage.token = 'old-access';
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'invalid refresh'},
      );

      await Future.wait<void>(<Future<void>>[
        expectLater(
          consumer.get('/one'),
          throwsA(isA<UnauthorizedException>()),
        ),
        expectLater(
          consumer.get('/two'),
          throwsA(isA<UnauthorizedException>()),
        ),
      ]);

      expect(refreshAdapter.calls, 1);
      expect(sessionExpiredCount, 1);
      expect(storage.token, isNull);
    });

    test(
      'does not clear tokens when refresh throws an unexpected error',
      () async {
        storage.token = 'old-access';
        RefreshTokenHelper.instance.init(
          tokenStorage: storage,
          userTypeStorage: userTypeStorage,
          refreshClient: refreshDio,
          languageCode: () => throw StateError('language missing'),
          onSessionExpired: () async {
            sessionExpiredCount++;
          },
        );
        mainAdapter.handler = (_) => jsonBody(
          StatusCode.unauthorized,
          <String, dynamic>{'message': 'expired'},
        );

        await expectLater(
          consumer.get('/student/profile/edit'),
          throwsA(isA<UnauthorizedException>()),
        );
        expect(storage.token, 'old-access');
        expect(refreshAdapter.calls, 0);
        expect(sessionExpiredCount, 0);
      },
    );

    test('rejects the original error when token storage throws', () async {
      storage
        ..token = 'old-access'
        ..readError = StateError('storage down')
        ..throwOnRead = 2;
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(refreshAdapter.calls, 0);
    });

    test('rejects the retry error when retriedOptions fails', () async {
      storage
        ..token = 'old-access'
        ..readError = StateError('storage down')
        ..throwOnRead = 4;
      mainAdapter.handler = (_) => jsonBody(
        StatusCode.unauthorized,
        <String, dynamic>{'message': 'expired'},
      );
      refreshAdapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'data': <String, dynamic>{'access_token': 'new-access'},
      });

      await expectLater(
        consumer.get('/student/profile/edit'),
        throwsA(isA<ServerException>()),
      );
      expect(refreshAdapter.calls, 1);
      expect(storage.token, 'new-access');
      expect(sessionExpiredCount, 0);
    });
  });

  test('factory returns the singleton', () {
    expect(ApiInterceptor(), same(ApiInterceptor.instance));
  });
}
