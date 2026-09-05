import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/core/api/api_constants.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/utils/enums.dart';

void main() {
  tearDown(() => AppFlavor.activate(AppFlavor.dev));

  test('baseUrl follows the active flavor', () {
    AppFlavor.activate(AppFlavor.live);
    expect(ApiConstants.baseUrl, ApiConstants.live);

    AppFlavor.activate(AppFlavor.dev);
    expect(ApiConstants.baseUrl, ApiConstants.dev);
  });

  test('exposes auth paths and header names', () {
    expect(ApiConstants.refreshTokenPath, '/common/refresh-token');
    expect(ApiConstants.loginPath, '/auth/login');
    expect(ApiConstants.registerPath, '/auth/register');
    expect(ApiConstants.forgotPasswordPath, '/auth/forgot-password');
    expect(ApiConstants.resetPasswordPath, '/auth/reset-password');
    expect(ApiConstants.verifyEmailPath, '/auth/verify-email');
    expect(ApiConstants.verifyPhoneNumberPath, '/auth/verify-phone-number');
    expect(ApiHeaders.accept, 'accept');
    expect(ApiHeaders.acceptLanguage, 'accept-language');
    expect(ApiHeaders.authorization, 'authorization');
    expect(ApiHeaders.location, 'location');
  });

  test('matches public auth paths including absolute URLs', () {
    expect(ApiConstants.isPublicAuthPath(ApiConstants.loginPath), isTrue);
    expect(ApiConstants.isPublicAuthPath(ApiConstants.registerPath), isTrue);
    expect(
      ApiConstants.isPublicAuthPath(
        'https://example.test/v1/api${ApiConstants.resetPasswordPath}',
      ),
      isTrue,
    );
    expect(ApiConstants.isPublicAuthPath('/student/profile/edit'), isFalse);
    expect(
      ApiConstants.isPublicAuthPath('${ApiConstants.loginPath}-extra'),
      isFalse,
    );
    expect(
      ApiConstants.matchesPath(
        'https://example.test/v1/api${ApiConstants.refreshTokenPath}',
        ApiConstants.refreshTokenPath,
      ),
      isTrue,
    );
  });

  test('omits log bodies for public auth and refresh paths', () {
    expect(ApiConstants.shouldOmitLogBody(ApiConstants.loginPath), isTrue);
    expect(
      ApiConstants.shouldOmitLogBody(ApiConstants.resetPasswordPath),
      isTrue,
    );
    expect(
      ApiConstants.shouldOmitLogBody(ApiConstants.refreshTokenPath),
      isTrue,
    );
    expect(ApiConstants.shouldOmitLogBody('/student/profile/edit'), isFalse);
  });

  test('refresh timeouts are shorter than upload receive timeout', () {
    expect(ApiTimeouts.refreshReceive, const Duration(seconds: 30));
    expect(
      ApiTimeouts.receive.inSeconds > ApiTimeouts.refreshReceive.inSeconds,
      isTrue,
    );
  });

  test('status codes match HTTP semantics', () {
    expect(StatusCode.ok, 200);
    expect(StatusCode.created, 201);
    expect(StatusCode.accepted, 202);
    expect(StatusCode.noContent, 204);
    expect(StatusCode.movedPermanently, 301);
    expect(StatusCode.found, 302);
    expect(StatusCode.seeOther, 303);
    expect(StatusCode.notModified, 304);
    expect(StatusCode.temporaryRedirect, 307);
    expect(StatusCode.permanentRedirect, 308);
    expect(StatusCode.badRequest, 400);
    expect(StatusCode.unauthorized, 401);
    expect(StatusCode.forbidden, 403);
    expect(StatusCode.notFound, 404);
    expect(StatusCode.methodNotAllowed, 405);
    expect(StatusCode.requestTimeout, 408);
    expect(StatusCode.conflict, 409);
    expect(StatusCode.gone, 410);
    expect(StatusCode.payloadTooLarge, 413);
    expect(StatusCode.unsupportedMediaType, 415);
    expect(StatusCode.unProcessableContent, 422);
    expect(StatusCode.tooManyRequests, 429);
    expect(StatusCode.internalServerError, 500);
    expect(StatusCode.notImplemented, 501);
    expect(StatusCode.badGateway, 502);
    expect(StatusCode.serviceUnavailable, 503);
    expect(StatusCode.gatewayTimeout, 504);
  });
}
