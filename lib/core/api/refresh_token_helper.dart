import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:language/language.dart';

import '../error/exceptions.dart';
import '../services/local_storage/impl/access_token_storage.dart';
import '../services/local_storage/interfaces/local_storage_interface.dart';
import 'api_constants.dart';
import 'dio_http_adapter.dart';
import 'status_code.dart';

final class RefreshTokenHelper {
  RefreshTokenHelper._();

  static final RefreshTokenHelper instance = ._();

  factory RefreshTokenHelper() => instance;

  static const String retriedRequestExtraKey = 'accessTokenRetried';

  LocalStorageInterface? _tokenStorage;
  Dio? _refreshClient;
  String Function()? _languageCode;
  Dio? _lazyRefreshClient;
  Completer<void>? _refreshLock;

  /// Optional overrides. Production uses GetIt / [Language.instance].
  void init({
    LocalStorageInterface? tokenStorage,
    Dio? refreshClient,
    String Function()? languageCode,
  }) {
    _tokenStorage = tokenStorage;
    _refreshClient = refreshClient;
    _languageCode = languageCode;
    _lazyRefreshClient = null;
    _refreshLock = null;
  }

  @visibleForTesting
  void reset() {
    _tokenStorage = null;
    _refreshClient = null;
    _languageCode = null;
    _lazyRefreshClient = null;
    _refreshLock = null;
  }

  LocalStorageInterface get tokenStorage =>
      _tokenStorage ?? GetIt.instance<AccessTokenStorage>();

  Dio get refreshClient =>
      _refreshClient ?? (_lazyRefreshClient ??= _createRefreshClient());

  String Function() get languageCode =>
      _languageCode ?? () => Language.instance.currentCode;

  Future<String?> accessToken() => tokenStorage.read();

  Future<bool> shouldRefresh(DioException err) async {
    if (err.response?.statusCode != StatusCode.unauthorized) {
      return false;
    }
    if (err.requestOptions.extra[retriedRequestExtraKey] == true) {
      return false;
    }
    if (isRefreshPath(err.requestOptions.path)) {
      return false;
    }
    if (err.requestOptions.headers[HttpHeaders.authorizationHeader] == null) {
      return false;
    }

    final String? storedAccessToken = await tokenStorage.read();
    return _hasValue(storedAccessToken);
  }

  RequestOptions retriedOptions(RequestOptions options) {
    return options.copyWith(
      extra: <String, dynamic>{...options.extra, retriedRequestExtraKey: true},
    );
  }

  Future<void> refresh() {
    final Completer<void>? inFlight = _refreshLock;
    if (inFlight != null) {
      return inFlight.future;
    }

    final Completer<void> completer = Completer<void>();
    _refreshLock = completer;
    _performRefresh()
        .then(
          (_) {
            completer.complete();
          },
          onError: (Object error, StackTrace stackTrace) {
            completer.completeError(error, stackTrace);
          },
        )
        .whenComplete(() {
          if (identical(_refreshLock, completer)) {
            _refreshLock = null;
          }
        });
    return completer.future;
  }

  Future<void> clearAuthTokens() async {
    await tokenStorage.remove();
  }

  bool isRefreshPath(String path) =>
      path.endsWith(ApiConstants.refreshTokenPath) ||
      path.contains(ApiConstants.refreshTokenPath);

  Future<void> _performRefresh() async {
    final String? currentAccessToken = await tokenStorage.read();
    if (!_hasValue(currentAccessToken)) {
      throw const UnauthorizedException();
    }

    final Response<dynamic> response = await refreshClient.post<dynamic>(
      ApiConstants.refreshTokenPath,
      options: Options(
        headers: <String, dynamic>{
          HttpHeaders.acceptHeader: 'application/json',
          HttpHeaders.acceptLanguageHeader: languageCode(),
          HttpHeaders.authorizationHeader: 'Bearer $currentAccessToken',
        },
      ),
    );

    final String? newAccessToken = parseAccessToken(response.data);
    if (newAccessToken == null) {
      throw const UnauthorizedException();
    }

    await tokenStorage.save(value: newAccessToken);
  }

  Dio _createRefreshClient() {
    final Dio client = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        contentType: 'application/json',
        connectTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    applyTrustingHttpAdapter(client);
    return client;
  }

  static String? parseAccessToken(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final dynamic payload = data['data'] is Map ? data['data'] : data;
    if (payload is! Map) {
      return null;
    }

    final String? parsedAccessToken = _readToken(payload, const <String>[
      'access_token',
      'accessToken',
      'token',
    ]);
    if (parsedAccessToken == null || parsedAccessToken.isEmpty) {
      return null;
    }
    return parsedAccessToken;
  }

  static String? _readToken(Map<dynamic, dynamic> payload, List<String> keys) {
    for (final String key in keys) {
      final Object? value = payload[key];
      if (value != null) {
        return value.toString();
      }
    }
    return null;
  }

  bool _hasValue(String? value) => value != null && value.isNotEmpty;
}
