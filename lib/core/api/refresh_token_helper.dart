import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:language/language.dart';

import '../error/exceptions.dart';
import '../services/local_storage/impl/access_token_storage.dart';
import '../services/local_storage/impl/user_type_storage.dart';
import '../services/local_storage/interfaces/local_storage_interface.dart';
import '../utils/enums.dart';
import 'api_constants.dart';
import 'dio_exception_mapper.dart';
import 'dio_http_adapter.dart';
import 'redirect_interceptor.dart';
import 'status_code.dart';

final class RefreshTokenHelper {
  RefreshTokenHelper._();

  static final RefreshTokenHelper instance = ._();

  factory RefreshTokenHelper() => instance;

  static const String retriedRequestExtraKey = 'accessTokenRetried';

  LocalStorageInterface? _tokenStorage;
  LocalStorageInterface? _userTypeStorage;
  Dio? _refreshClient;
  String Function()? _languageCode;
  Future<void> Function()? _onSessionExpired;
  Dio? _lazyRefreshClient;
  Completer<void>? _refreshLock;
  Completer<void>? _invalidateLock;

  /// Optional overrides. Production uses GetIt / [Language.instance].
  void init({
    LocalStorageInterface? tokenStorage,
    LocalStorageInterface? userTypeStorage,
    Dio? refreshClient,
    String Function()? languageCode,
    Future<void> Function()? onSessionExpired,
  }) {
    _tokenStorage = tokenStorage;
    _userTypeStorage = userTypeStorage;
    _refreshClient = refreshClient;
    _languageCode = languageCode;
    _onSessionExpired = onSessionExpired;
    _lazyRefreshClient = null;
    _refreshLock = null;
    _invalidateLock = null;
  }

  /// Registers navigation / UI cleanup after [invalidateSession].
  void setOnSessionExpired(Future<void> Function()? callback) {
    _onSessionExpired = callback;
  }

  @visibleForTesting
  void reset() {
    _tokenStorage = null;
    _userTypeStorage = null;
    _refreshClient = null;
    _languageCode = null;
    _onSessionExpired = null;
    _lazyRefreshClient = null;
    _refreshLock = null;
    _invalidateLock = null;
  }

  LocalStorageInterface get tokenStorage =>
      _tokenStorage ?? GetIt.instance<AccessTokenStorage>();

  LocalStorageInterface get userTypeStorage =>
      _userTypeStorage ?? GetIt.instance<UserTypeStorage>();

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
    if (ApiConstants.isPublicAuthPath(err.requestOptions.path)) {
      return false;
    }
    if (err.requestOptions.headers[ApiHeaders.authorization] == null) {
      return false;
    }

    final String? storedAccessToken = await tokenStorage.read();
    return _hasValue(storedAccessToken);
  }

  Future<RequestOptions> retriedOptions(RequestOptions options) async {
    final String? accessToken = await tokenStorage.read();
    final Map<String, dynamic> headers = .from(options.headers);
    if (_hasValue(accessToken)) {
      headers[ApiHeaders.authorization] = 'Bearer $accessToken';
    } else {
      headers.remove(ApiHeaders.authorization);
    }

    return options.copyWith(
      headers: headers,
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

  /// Clears the access token, marks the user as a guest, and notifies the app.
  /// Concurrent callers share one run so splash navigation fires once.
  Future<void> invalidateSession() {
    final Completer<void>? inFlight = _invalidateLock;
    if (inFlight != null) {
      return inFlight.future;
    }

    final Completer<void> completer = Completer<void>();
    _invalidateLock = completer;
    _performInvalidate()
        .then(
          (_) {
            completer.complete();
          },
          onError: (Object error, StackTrace stackTrace) {
            completer.completeError(error, stackTrace);
          },
        )
        .whenComplete(() {
          if (identical(_invalidateLock, completer)) {
            _invalidateLock = null;
          }
        });
    return completer.future;
  }

  Future<void> _performInvalidate() async {
    await clearAuthTokens();
    await userTypeStorage.save(value: UserType.guest.name);
    await _onSessionExpired?.call();
  }

  bool isRefreshPath(String path) {
    return ApiConstants.matchesPath(path, ApiConstants.refreshTokenPath);
  }

  Future<void> _performRefresh() async {
    final String? currentAccessToken = await tokenStorage.read();
    if (!_hasValue(currentAccessToken)) {
      throw const UnauthorizedException();
    }

    final Response<dynamic> response = await refreshClient.post<dynamic>(
      ApiConstants.refreshTokenPath,
      options: Options(
        headers: <String, dynamic>{
          ApiHeaders.accept: 'application/json',
          ApiHeaders.acceptLanguage: languageCode(),
          ApiHeaders.authorization: 'Bearer $currentAccessToken',
        },
      ),
    );

    final String? newAccessToken = parseAccessToken(response.data);
    if (newAccessToken == null) {
      throw UnauthorizedException(message: extractErrorMessage(response.data));
    }

    final bool saved = await tokenStorage.save(value: newAccessToken);
    if (!saved) {
      throw const CacheException(message: 'Failed to persist access token');
    }
  }

  Dio _createRefreshClient() {
    final Dio client = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        contentType: Headers.jsonContentType,
        connectTimeout: ApiTimeouts.refreshConnect,
        sendTimeout: ApiTimeouts.refreshSend,
        receiveTimeout: ApiTimeouts.refreshReceive,
        followRedirects: false,
      ),
    );
    applyHttpAdapter(client);
    applyRedirectPolicy(client);
    addRedirectInterceptor(client);
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
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  bool _hasValue(String? value) => value != null && value.isNotEmpty;
}
