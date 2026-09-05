import 'package:dio/dio.dart';

import 'api_constants.dart';
import 'status_code.dart';

/// Follows 3xx responses without sending [Authorization] to another origin.
final class SafeRedirectInterceptor extends Interceptor {
  SafeRedirectInterceptor(this._client);

  static const String redirectCountExtraKey = 'redirectCount';
  static const String omitAuthorizationExtraKey = 'omitAuthorization';
  static const int maxRedirects = 5;

  static const Set<int> _redirectStatusCodes = <int>{
    StatusCode.movedPermanently,
    StatusCode.found,
    StatusCode.seeOther,
    StatusCode.temporaryRedirect,
    StatusCode.permanentRedirect,
  };

  final Dio _client;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldFollow(err)) {
      handler.next(err);
      return;
    }

    try {
      final Response<dynamic> response = await _client.fetch<dynamic>(
        _nextOptions(err),
      );
      handler.resolve(response);
    } on DioException catch (redirectError) {
      handler.next(redirectError);
    }
  }

  bool _shouldFollow(DioException err) {
    final int? statusCode = err.response?.statusCode;
    if (statusCode == null || !_redirectStatusCodes.contains(statusCode)) {
      return false;
    }
    final String? location = _location(err.response);
    if (location == null) {
      return false;
    }
    final Object? count = err.requestOptions.extra[redirectCountExtraKey];
    final int redirects = count is int ? count : 0;
    if (redirects >= maxRedirects) {
      return false;
    }
    return _isCrossOriginFollowSafe(
      original: err.requestOptions,
      location: location,
      statusCode: statusCode,
    );
  }

  /// Cross-origin follows are GET/HEAD (or 303, which we convert to GET).
  /// 307/308 would otherwise replay POST/PUT bodies to another host.
  bool _isCrossOriginFollowSafe({
    required RequestOptions original,
    required String location,
    required int statusCode,
  }) {
    final Uri nextUri = original.uri.resolve(location);
    final bool isCrossOrigin =
        original.uri.host != nextUri.host ||
        original.uri.scheme != nextUri.scheme;
    if (!isCrossOrigin) {
      return true;
    }
    if (statusCode == StatusCode.seeOther) {
      return true;
    }
    final String method = original.method.toUpperCase();
    return method == 'GET' || method == 'HEAD';
  }

  RequestOptions _nextOptions(DioException err) {
    final RequestOptions original = err.requestOptions;
    final Uri nextUri = original.uri.resolve(_location(err.response)!);
    final Object? count = original.extra[redirectCountExtraKey];
    final int redirects = count is int ? count : 0;
    final bool isCrossOrigin =
        original.uri.host != nextUri.host ||
        original.uri.scheme != nextUri.scheme;

    String method = original.method;
    if (err.response?.statusCode == StatusCode.seeOther) {
      method = 'GET';
    }

    final Map<String, dynamic> headers = .from(original.headers);
    if (isCrossOrigin) {
      headers.remove(ApiHeaders.authorization);
    }

    final RequestOptions next = original.copyWith(
      path: nextUri.toString(),
      method: method,
      headers: headers,
      extra: <String, dynamic>{
        ...original.extra,
        redirectCountExtraKey: redirects + 1,
        if (isCrossOrigin) omitAuthorizationExtraKey: true,
      },
    );
    if (err.response?.statusCode == StatusCode.seeOther) {
      next.data = null;
    }
    return next;
  }

  String? _location(Response<dynamic>? response) {
    final String? location = response?.headers.value(ApiHeaders.location);
    if (location == null || location.isEmpty) {
      return null;
    }
    return location;
  }
}

void applyRedirectPolicy(Dio client) {
  client.options.followRedirects = false;
}

void addRedirectInterceptor(Dio client) {
  if (client.interceptors.whereType<SafeRedirectInterceptor>().isNotEmpty) {
    return;
  }
  client.interceptors.insert(0, SafeRedirectInterceptor(client));
}
