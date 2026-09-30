import '../../../../config/language/strings.dart';
import '../../../../core/api/status_code.dart';
import '../../../../core/error/failures.dart';

abstract final class AuthErrorCopy {
  static const String _codeField = 'code';
  static const Set<String> _tokenFieldKeys = <String>{
    'registration_token',
    'token',
  };

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
    if (failure is ValidationFailure &&
        failure.fieldErrors.isNotEmpty &&
        !_isOtpCodeFailure(failure)) {
      return failure.fieldErrors;
    }
    final String copy = of(failure, otp: true);
    if (failure is ValidationFailure && failure.fieldErrors.isNotEmpty) {
      return <String, List<String>>{
        ...failure.fieldErrors,
        _codeField: <String>[copy],
      };
    }
    return <String, List<String>>{
      _codeField: <String>[copy],
    };
  }

  static String _otpCopy(Failure failure) {
    if (!_isOtpCodeFailure(failure)) {
      return failure.message ?? Strings.pleaseTryAgainLater;
    }
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
    if (_hasNonTokenFieldErrors(failure)) {
      return false;
    }
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

  static bool _hasNonTokenFieldErrors(Failure failure) {
    if (failure is! ValidationFailure) {
      return false;
    }
    return failure.fieldErrors.keys.any(
      (String key) => !_tokenFieldKeys.contains(key),
    );
  }

  static bool _isOtpCodeFailure(Failure failure) {
    if (failure is! ValidationFailure || failure.fieldErrors.isEmpty) {
      return true;
    }
    return failure.fieldErrors.containsKey(_codeField);
  }

  static bool _codeFieldLooksExpired(Failure failure) {
    if (failure is! ValidationFailure) {
      return false;
    }
    return failure.fieldErrors[_codeField]?.any(_looksExpired) ?? false;
  }

  static bool _looksExpired(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }
    final String lower = text.toLowerCase();
    return lower.contains('expir') || lower.contains('gone');
  }
}
