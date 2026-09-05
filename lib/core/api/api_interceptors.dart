import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:language/language.dart';

import '../error/exceptions.dart';
import 'api_constants.dart';
import 'dio_exception_mapper.dart';
import 'redirect_interceptor.dart';
import 'refresh_token_helper.dart';

final class ApiInterceptor extends Interceptor {
  ApiInterceptor._();

  static final ApiInterceptor instance = ._();

  factory ApiInterceptor() => instance;

  Dio? _retryClient;
  RefreshTokenHelper? _refreshTokenHelper;
  String Function()? _getLanguageCode;

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
    DioExceptionMapper.instance.init(noInternetMessage: noInternetMessage);
  }

  @visibleForTesting
  void reset() {
    _retryClient = null;
    _refreshTokenHelper = null;
    _getLanguageCode = null;
  }

  RefreshTokenHelper get refreshTokenHelper => _refreshTokenHelper ?? .instance;

  String Function() get getLanguageCode =>
      _getLanguageCode ?? () => Language.instance.currentCode;

  Dio get retryClient => _retryClient ?? GetIt.instance<Dio>();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      await _attachHeaders(options);
      handler.next(options);
    } catch (error, stackTrace) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: error,
          stackTrace: stackTrace,
        ),
      );
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
      } on AppException catch (refreshError) {
        if (_isUnrecoverableRefreshFailure(refreshError)) {
          await refreshTokenHelper.invalidateSession();
        }
        handler.reject(_wrap(err, refreshError));
        return;
      } catch (_) {
        handler.reject(_asAppException(err));
        return;
      }

      try {
        final Response<dynamic> response = await retryClient.fetch<dynamic>(
          await refreshTokenHelper.retriedOptions(err.requestOptions),
        );
        handler.resolve(response);
      } on DioException catch (retryError) {
        if (_exceptionFrom(retryError) is UnauthorizedException) {
          await refreshTokenHelper.invalidateSession();
        }
        handler.reject(_asAppException(retryError));
      } catch (retryError) {
        handler.reject(_wrapUnexpected(err, retryError));
      }
    } catch (_) {
      handler.reject(_asAppException(err));
    }
  }

  Future<void> _attachHeaders(RequestOptions options) async {
    options.headers[ApiHeaders.accept] = 'application/json';
    options.headers[ApiHeaders.acceptLanguage] = getLanguageCode();

    if (ApiConstants.isPublicAuthPath(options.path) ||
        options.extra[SafeRedirectInterceptor.omitAuthorizationExtraKey] ==
            true) {
      options.headers.remove(ApiHeaders.authorization);
      return;
    }

    final String? accessToken = await refreshTokenHelper.accessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers[ApiHeaders.authorization] = 'Bearer $accessToken';
    } else {
      options.headers.remove(ApiHeaders.authorization);
    }
  }

  Future<DioException> _mapFailedRefresh(
    DioException original,
    DioException refreshError,
  ) async {
    final AppException mapped = _exceptionFrom(refreshError);
    if (_isUnrecoverableRefreshFailure(mapped)) {
      await refreshTokenHelper.invalidateSession();
      return _asAppException(original);
    }
    return _wrap(refreshError, mapped);
  }

  /// Refresh 401/403 (or a 200 with no token) means the session is dead.
  /// 5xx, 429, cancel, and connectivity must not log the user out.
  bool _isUnrecoverableRefreshFailure(AppException exception) {
    return exception is UnauthorizedException ||
        exception is ForbiddenException;
  }

  DioException _asAppException(DioException err) {
    final Object? cause = err.error;
    if (cause is AppException) {
      return err;
    }
    return _wrap(err, DioExceptionMapper.instance.map(err));
  }

  AppException _exceptionFrom(DioException err) {
    final Object? cause = err.error;
    if (cause is AppException) {
      return cause;
    }
    return DioExceptionMapper.instance.map(err);
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

  DioException _wrapUnexpected(DioException original, Object retryError) {
    if (retryError is AppException) {
      return _wrap(original, retryError);
    }
    return _wrap(original, ServerException(message: retryError.toString()));
  }
}
