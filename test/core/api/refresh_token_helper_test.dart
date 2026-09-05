import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/refresh_token_helper.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/exceptions.dart';

import 'helpers/api_test_doubles.dart';

void main() {
  group('parseAccessToken', () {
    test('reads camelCase and snake_case payloads', () {
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{
          'data': <String, dynamic>{'accessToken': 'a'},
        }),
        'a',
      );
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{
          'access_token': 'a2',
        }),
        'a2',
      );
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{'token': 'a3'}),
        'a3',
      );
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{'status': 'ok'}),
        isNull,
      );
    });

    test('rejects non-string and empty token values', () {
      expect(RefreshTokenHelper.parseAccessToken(null), isNull);
      expect(RefreshTokenHelper.parseAccessToken('token'), isNull);
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{
          'data': 'not-a-map',
        }),
        isNull,
      );
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{'token': 123}),
        isNull,
      );
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{
          'token': <String, dynamic>{'nested': true},
        }),
        isNull,
      );
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{'token': ''}),
        isNull,
      );
    });
  });

  group('RefreshTokenHelper.shouldRefresh', () {
    late FakeAccessTokenStorage storage;
    late RefreshTokenHelper helper;

    setUp(() {
      storage = FakeAccessTokenStorage();
      helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          refreshClient: Dio(),
          languageCode: () => 'en',
        );
    });

    tearDown(RefreshTokenHelper.instance.reset);

    test('returns false when the failure is not 401', () async {
      expect(
        await helper.shouldRefresh(_unauthorizedError(statusCode: 500)),
        isFalse,
      );
    });

    test('returns false when the request was already retried', () async {
      storage.token = 'token';
      expect(
        await helper.shouldRefresh(
          _unauthorizedError(
            extra: <String, dynamic>{
              RefreshTokenHelper.retriedRequestExtraKey: true,
            },
          ),
        ),
        isFalse,
      );
    });

    test('returns false for the refresh endpoint itself', () async {
      storage.token = 'token';
      expect(
        await helper.shouldRefresh(
          _unauthorizedError(path: ApiConstants.refreshTokenPath),
        ),
        isFalse,
      );
      expect(
        await helper.shouldRefresh(
          _unauthorizedError(
            path: 'https://example.test/v1/api${ApiConstants.refreshTokenPath}',
          ),
        ),
        isFalse,
      );
    });

    test(
      'returns false for public auth paths even with a stored token',
      () async {
        storage.token = 'token';
        expect(
          await helper.shouldRefresh(
            _unauthorizedError(path: ApiConstants.loginPath),
          ),
          isFalse,
        );
        expect(
          await helper.shouldRefresh(
            _unauthorizedError(path: ApiConstants.registerPath),
          ),
          isFalse,
        );
        expect(
          await helper.shouldRefresh(
            _unauthorizedError(
              path:
                  'https://example.test/v1/api${ApiConstants.forgotPasswordPath}',
            ),
          ),
          isFalse,
        );
      },
    );

    test('does not treat a substring path as the refresh endpoint', () {
      expect(
        helper.isRefreshPath('${ApiConstants.refreshTokenPath}-extra'),
        isFalse,
      );
      expect(helper.isRefreshPath(ApiConstants.refreshTokenPath), isTrue);
    });

    test('returns false when Authorization header is missing', () async {
      storage.token = 'token';
      expect(
        await helper.shouldRefresh(
          _unauthorizedError(includeAuthorization: false),
        ),
        isFalse,
      );
    });

    test('returns false when the stored access token is empty', () async {
      storage.token = '';
      expect(await helper.shouldRefresh(_unauthorizedError()), isFalse);
    });

    test(
      'returns true for an authenticated 401 with a stored access token',
      () async {
        storage.token = 'token';
        expect(await helper.shouldRefresh(_unauthorizedError()), isTrue);
      },
    );
  });

  group('RefreshTokenHelper.retriedOptions', () {
    test('stamps the retry flag and the current access token', () async {
      final FakeAccessTokenStorage storage = FakeAccessTokenStorage()
        ..token = 'new-access';
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          refreshClient: Dio(),
          languageCode: () => 'en',
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      final RequestOptions retried = await helper.retriedOptions(
        RequestOptions(
          path: '/profile',
          headers: <String, dynamic>{
            ApiHeaders.authorization: 'Bearer old-access',
          },
        ),
      );

      expect(retried.extra[RefreshTokenHelper.retriedRequestExtraKey], isTrue);
      expect(retried.headers[ApiHeaders.authorization], 'Bearer new-access');
    });

    test('removes Authorization when no access token is stored', () async {
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: FakeAccessTokenStorage(),
          refreshClient: Dio(),
          languageCode: () => 'en',
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      final RequestOptions retried = await helper.retriedOptions(
        RequestOptions(
          path: '/profile',
          headers: <String, dynamic>{
            ApiHeaders.authorization: 'Bearer old-access',
          },
        ),
      );

      expect(retried.headers.containsKey(ApiHeaders.authorization), isFalse);
    });
  });

  group('RefreshTokenHelper.refresh', () {
    late FakeAccessTokenStorage storage;
    late ScriptedAdapter refreshAdapter;
    late RefreshTokenHelper helper;

    setUp(() {
      storage = FakeAccessTokenStorage()..token = 'old-access';
      refreshAdapter = ScriptedAdapter();
      final Dio refreshClient = Dio(
        BaseOptions(baseUrl: 'https://example.test'),
      )..httpClientAdapter = refreshAdapter;
      helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          refreshClient: refreshClient,
          languageCode: () => 'en',
        );
    });

    tearDown(RefreshTokenHelper.instance.reset);

    test('persists a new access token from a 200 body', () async {
      refreshAdapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'data': <String, dynamic>{'access_token': 'new-access'},
      });

      await helper.refresh();

      expect(storage.token, 'new-access');
    });

    test('throws CacheException when persisting the new token fails', () async {
      storage.saveSucceeds = false;
      refreshAdapter.handler = (_) => jsonBody(StatusCode.ok, <String, dynamic>{
        'data': <String, dynamic>{'access_token': 'new-access'},
      });

      await expectLater(helper.refresh(), throwsA(isA<CacheException>()));
      expect(storage.token, 'old-access');
    });

    test(
      'throws UnauthorizedException when the 200 body has no token',
      () async {
        refreshAdapter.handler = (_) => jsonBody(
          StatusCode.ok,
          <String, dynamic>{'status': 'error', 'message': 'session ended'},
        );

        await expectLater(
          helper.refresh(),
          throwsA(
            isA<UnauthorizedException>().having(
              (UnauthorizedException e) => e.message,
              'message',
              'session ended',
            ),
          ),
        );
        expect(storage.token, 'old-access');
      },
    );

    test('throws UnauthorizedException when no stored token exists', () async {
      storage.token = null;

      await expectLater(
        helper.refresh(),
        throwsA(isA<UnauthorizedException>()),
      );
      expect(refreshAdapter.calls, 0);
    });

    test('shares one in-flight refresh', () async {
      refreshAdapter.handler = (_) async {
        await Future<void>.delayed(const Duration(milliseconds: 40));
        return jsonBody(StatusCode.ok, <String, dynamic>{
          'data': <String, dynamic>{'accessToken': 'new-access'},
        });
      };

      await Future.wait<void>(<Future<void>>[
        helper.refresh(),
        helper.refresh(),
      ]);

      expect(refreshAdapter.calls, 1);
      expect(storage.token, 'new-access');
    });
  });

  group('RefreshTokenHelper.clearAuthTokens', () {
    test('removes the stored access token', () async {
      final FakeAccessTokenStorage storage = FakeAccessTokenStorage()
        ..token = 'a';
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          refreshClient: Dio(),
          languageCode: () => 'en',
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      await helper.clearAuthTokens();

      expect(storage.token, isNull);
    });
  });

  group('RefreshTokenHelper.invalidateSession', () {
    test('clears the token, sets guest, and notifies the app', () async {
      final FakeAccessTokenStorage storage = FakeAccessTokenStorage()
        ..token = 'a';
      final FakeUserTypeStorage userTypes = FakeUserTypeStorage()
        ..value = 'loggedIn';
      int notified = 0;
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          userTypeStorage: userTypes,
          refreshClient: Dio(),
          languageCode: () => 'en',
          onSessionExpired: () async {
            notified++;
          },
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      await helper.invalidateSession();

      expect(storage.token, isNull);
      expect(userTypes.value, 'guest');
      expect(notified, 1);
    });

    test('setOnSessionExpired is used on the next invalidate', () async {
      final FakeAccessTokenStorage storage = FakeAccessTokenStorage()
        ..token = 'a';
      final FakeUserTypeStorage userTypes = FakeUserTypeStorage()
        ..value = 'loggedIn';
      int notified = 0;
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          userTypeStorage: userTypes,
          refreshClient: Dio(),
          languageCode: () => 'en',
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      helper.setOnSessionExpired(() async {
        notified++;
      });
      await helper.invalidateSession();

      expect(notified, 1);
    });

    test('concurrent invalidateSession notifies the app once', () async {
      final FakeAccessTokenStorage storage = FakeAccessTokenStorage()
        ..token = 'a';
      final FakeUserTypeStorage userTypes = FakeUserTypeStorage()
        ..value = 'loggedIn';
      int notified = 0;
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: storage,
          userTypeStorage: userTypes,
          refreshClient: Dio(),
          languageCode: () => 'en',
          onSessionExpired: () async {
            await Future<void>.delayed(const Duration(milliseconds: 20));
            notified++;
          },
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      await Future.wait<void>(<Future<void>>[
        helper.invalidateSession(),
        helper.invalidateSession(),
      ]);

      expect(notified, 1);
      expect(storage.token, isNull);
    });
  });

  group('RefreshTokenHelper factories', () {
    test('factory returns the singleton', () {
      expect(RefreshTokenHelper(), same(RefreshTokenHelper.instance));
    });

    test('creates a lazy refresh client with the flavor base URL', () {
      final RefreshTokenHelper helper = RefreshTokenHelper.instance
        ..init(
          tokenStorage: FakeAccessTokenStorage(),
          languageCode: () => 'en',
        );
      addTearDown(RefreshTokenHelper.instance.reset);

      expect(helper.refreshClient.options.baseUrl, ApiConstants.baseUrl);
      expect(
        helper.refreshClient.options.receiveTimeout,
        ApiTimeouts.refreshReceive,
      );
      expect(
        helper.refreshClient.options.connectTimeout,
        ApiTimeouts.refreshConnect,
      );
      expect(helper.refreshClient.options.followRedirects, isFalse);
      expect(helper.refreshClient, same(helper.refreshClient));
    });
  });
}

DioException _unauthorizedError({
  int statusCode = StatusCode.unauthorized,
  String path = '/profile',
  Map<String, dynamic>? extra,
  bool includeAuthorization = true,
}) {
  final RequestOptions requestOptions = RequestOptions(
    path: path,
    extra: extra ?? <String, dynamic>{},
    headers: <String, dynamic>{
      if (includeAuthorization) ApiHeaders.authorization: 'Bearer token',
    },
  );
  return DioException(
    requestOptions: requestOptions,
    type: .badResponse,
    response: Response<dynamic>(
      requestOptions: requestOptions,
      statusCode: statusCode,
    ),
  );
}
