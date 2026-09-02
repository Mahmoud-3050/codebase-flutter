import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:language/language.dart';

import '../../config/language/strings.dart';
import '../error/exceptions.dart';
import 'dio_exception_mapper.dart';
import 'refresh_token_helper.dart';

final class ApiInterceptor extends Interceptor {
  ApiInterceptor._();

  static final ApiInterceptor instance = ._();

  factory ApiInterceptor() => instance;

  Dio? _retryClient;
  RefreshTokenHelper? _refreshTokenHelper;
  String Function()? _getLanguageCode;
  String Function()? _noInternetMessage;
  DioExceptionMapper? _mapper;

  /// Optional overrides. Production uses GetIt / [Language.instance].
  void init({
    Dio? retryClient,
    RefreshTokenHelper? refreshTokenHelper,
    String Function()? getLanguageCode,
    String Function()? noInternetMessage,
  }) {
    _retryClient = retryClient;
    _refreshTokenHelper = refreshTokenHelper;
    _getLanguageCode = getLanguageCode;
    _noInternetMessage = noInternetMessage;
    _mapper = null;
  }

  @visibleForTesting
  void reset() {
    _retryClient = null;
    _refreshTokenHelper = null;
    _getLanguageCode = null;
    _noInternetMessage = null;
    _mapper = null;
  }

  RefreshTokenHelper get refreshTokenHelper =>
      _refreshTokenHelper ?? .instance;

  String Function() get getLanguageCode =>
      _getLanguageCode ?? () => Language.instance.currentCode;

  DioExceptionMapper get _resolvedMapper =>
      _mapper ??= DioExceptionMapper(
        noInternetMessage: _noInternetMessage ?? () => Strings.noInternetConnection,
      );

  Dio get retryClient => _retryClient ?? GetIt.instance<Dio>();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      await _attachHeaders(options);
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(DioException(requestOptions: options, error: error, stackTrace: stackTrace));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      if (!await refreshTokenHelper.shouldRefresh(err)) {
        handler.reject(_asAppException(err));
        return;
      }

      try {
        await refreshTokenHelper.refresh();
      } on DioException catch (refreshError) {
        handler.reject(await _mapFailedRefresh(err, refreshError));
        return;
      } catch (_) {
        await refreshTokenHelper.clearAuthTokens();
        handler.reject(_asAppException(err));
        return;
      }

      try {
        final Response<dynamic> response = await retryClient.fetch<dynamic>(
          refreshTokenHelper.retriedOptions(err.requestOptions),
        );
        handler.resolve(response);
      } on DioException catch (retryError) {
        handler.reject(_asAppException(retryError));
      }
    } catch (_) {
      handler.reject(_asAppException(err));
    }
  }

  Future<void> _attachHeaders(RequestOptions options) async {
    options.headers[HttpHeaders.acceptHeader] = 'application/json';
    options.headers[HttpHeaders.acceptLanguageHeader] = getLanguageCode();

    final String? accessToken = await refreshTokenHelper.accessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[HttpHeaders.authorizationHeader] = 'Bearer $accessToken';
    } else {
      options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  Future<DioException> _mapFailedRefresh(DioException original, DioException refreshError) async {
    final AppException mapped = _exceptionFrom(refreshError);
    if (mapped is InternetConnectionException) {
      return _wrap(refreshError, mapped);
    }
    await refreshTokenHelper.clearAuthTokens();
    return _asAppException(original);
  }

  DioException _asAppException(DioException err) {
    final Object? cause = err.error;
    if (cause is AppException) {
      return err;
    }
    return _wrap(err, _resolvedMapper.map(err));
  }

  AppException _exceptionFrom(DioException err) {
    final Object? cause = err.error;
    if (cause is AppException) {
      return cause;
    }
    return _resolvedMapper.map(err);
  }

  DioException _wrap(DioException err, AppException cause) {
    return DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: cause,
      message: cause.message,
    );
  }
}
