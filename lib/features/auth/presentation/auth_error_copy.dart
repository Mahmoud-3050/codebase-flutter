import '../../../../config/language/strings.dart';
import '../../../../core/api/status_code.dart';
import '../../../../core/error/failures.dart';

abstract final class AuthErrorCopy {
  static String of(
    Failure failure, {
    bool draftConflict = false,
    bool otp = false,
  }) {
    if (failure is NetworkFailure) {
      return Strings.noInternet;
    }
    if (failure is ServerFailure &&
        failure.statusCode == StatusCode.tooManyRequests) {
      return Strings.tooManyAttempts;
    }
    if (otp) {
      return _otpCopy(failure);
    }
    if (draftConflict && _isDraftExpiredFailure(failure)) {
      return Strings.draftExpired;
    }
    if (failure is UnauthorizedFailure) {
      return Strings.invalidCredentials;
    }
    if (failure is ServerFailure && failure.statusCode == StatusCode.conflict) {
      return Strings.emailTaken;
    }
    return failure.message ?? Strings.pleaseTryAgainLater;
  }

  static Map<String, List<String>> otpFieldErrors(Failure failure) {
    final String copy = of(failure, otp: true);
    if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
      return <String, List<String>>{
        ...failure.fieldErrors,
        'code': <String>[copy],
      };
    }
    return <String, List<String>>{
      'code': <String>[copy],
    };
  }

  static String _otpCopy(Failure failure) {
    if (failure is ServerFailure && failure.statusCode == StatusCode.gone) {
      return Strings.expiredCode;
    }
    if (failure is ServerFailure && failure.statusCode == StatusCode.conflict) {
      return Strings.expiredCode;
    }
    if (_looksExpired(failure.message) || _codeFieldLooksExpired(failure)) {
      return Strings.expiredCode;
    }
    return Strings.invalidCode;
  }

  static bool _isDraftExpiredFailure(Failure failure) {
    if (failure is ValidationFailure) {
      return true;
    }
    if (failure is ServerFailure) {
      return failure.statusCode == StatusCode.conflict ||
          failure.statusCode == StatusCode.unProcessableContent ||
          failure.statusCode == StatusCode.gone;
    }
    return false;
  }

  static bool _codeFieldLooksExpired(Failure failure) {
    if (failure is! ValidationFailure) {
      return false;
    }
    return failure.fieldErrors['code']?.any(_looksExpired) ?? false;
  }

  static bool _looksExpired(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }
    final String lower = text.toLowerCase();
    return lower.contains('expir') || lower.contains('gone');
  }
}
