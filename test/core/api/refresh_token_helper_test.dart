import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/refresh_token_helper.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/services/local_storage/access_token_storage.dart';

void main() {
  group('parseAccessToken', () {
    test('reads camelCase and snake_case payloads', () {
      expect(
        RefreshTokenHelper.parseAccessToken(<String, dynamic>{
          'data': <String, dynamic>{
            'accessToken': 'a',
          },
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
        RefreshTokenHelper.parseAccessToken(
          <String, dynamic>{'status': 'ok'},
        ),
        isNull,
      );
    });
  });

  group('RefreshTokenHelper.shouldRefresh', () {
    late FakeAccessTokenStorage storage;
    late RefreshTokenHelper helper;

    setUp(() {
      storage = FakeAccessTokenStorage();
      helper = RefreshTokenHelper(
        tokenStorage: storage,
        refreshClient: Dio(),
        languageCode: () => 'en',
      );
    });

    test('returns false when the failure is not 401', () async {
      expect(await helper.shouldRefresh(_unauthorizedError(statusCode: 500)),
          isFalse);
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
    });

    test('returns true for an authenticated 401 with a stored access token',
        () async {
      storage.token = 'token';
      expect(await helper.shouldRefresh(_unauthorizedError()), isTrue);
    });
  });

  group('RefreshTokenHelper.clearAuthTokens', () {
    test('removes the stored access token', () async {
      final FakeAccessTokenStorage storage = FakeAccessTokenStorage()
        ..token = 'a';
      final RefreshTokenHelper helper = RefreshTokenHelper(
        tokenStorage: storage,
        refreshClient: Dio(),
        languageCode: () => 'en',
      );

      await helper.clearAuthTokens();

      expect(storage.token, isNull);
    });
  });
}

DioException _unauthorizedError({
  int statusCode = StatusCode.unauthorized,
  String path = '/profile',
  Map<String, dynamic>? extra,
}) {
  final RequestOptions requestOptions = RequestOptions(
    path: path,
    extra: extra ?? <String, dynamic>{},
    headers: <String, dynamic>{
      'authorization': 'Bearer token',
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

class FakeAccessTokenStorage implements AccessTokenStorage {
  String? token;

  @override
  Future<String?> read() async => token;

  @override
  Future<void> save(String value) async => token = value;

  @override
  Future<void> remove() async => token = null;
}
