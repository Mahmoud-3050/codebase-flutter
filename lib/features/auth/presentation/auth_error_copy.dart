import '../../../../config/language/strings.dart';
import '../../../../core/api/status_code.dart';
import '../../../../core/error/failures.dart';

abstract final class AuthErrorCopy {
  static String of(Failure failure, {bool draftConflict = false}) {
    if (failure is NetworkFailure) {
      return Strings.noInternet;
    }
    if (failure is UnauthorizedFailure) {
      return Strings.invalidCredentials;
    }
    if (failure is ServerFailure &&
        failure.statusCode == StatusCode.tooManyRequests) {
      return Strings.tooManyAttempts;
    }
    if (failure is ServerFailure && failure.statusCode == StatusCode.conflict) {
      return draftConflict ? Strings.draftExpired : Strings.emailTaken;
    }
    return failure.message ?? Strings.pleaseTryAgainLater;
  }
}
