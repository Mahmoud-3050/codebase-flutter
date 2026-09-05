abstract final class StatusCode {
  // 2xx success
  static const int ok = 200;
  static const int created = 201;
  static const int accepted = 202;
  static const int noContent = 204;

  // 3xx redirection
  static const int movedPermanently = 301;
  static const int found = 302;
  static const int seeOther = 303;
  static const int notModified = 304;
  static const int temporaryRedirect = 307;
  static const int permanentRedirect = 308;

  // 4xx client errors
  static const int badRequest = 400;
  static const int unauthorized = 401;
  static const int forbidden = 403;
  static const int notFound = 404;
  static const int methodNotAllowed = 405;
  static const int requestTimeout = 408;
  static const int conflict = 409;
  static const int gone = 410;
  static const int payloadTooLarge = 413;
  static const int unsupportedMediaType = 415;
  static const int unProcessableContent = 422;
  static const int tooManyRequests = 429;

  // 5xx server errors
  static const int internalServerError = 500;
  static const int notImplemented = 501;
  static const int badGateway = 502;
  static const int serviceUnavailable = 503;
  static const int gatewayTimeout = 504;
}
