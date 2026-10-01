import '../../../../config/language/strings.dart';
import '../../../../core/api/status_code.dart';
import '../../../../core/error/failures.dart';

abstract final class AuthErrorCopy {
  static const String _codeField = 'code';
  static const Set<String> _tokenFieldKeys = <String>{
    'registration_token',
    'token',
  };

  /// 422 is both a wrong code and an expired code. The contract says the
  /// expired case explains that the user must request a new one.
  static const List<String> _expiredMarkers = <String>['expir', 'gone'];

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
    if (_isExpiredOtp(failure)) {
      return Strings.expiredCode;
    }
    if (_statusCode(failure) == StatusCode.conflict) {
      return Strings.codeAlreadyUsed;
    }
    return Strings.invalidCode;
  }

  static int? _statusCode(Failure failure) {
    return switch (failure) {
      ServerFailure(:final statusCode) => statusCode,
      ValidationFailure(:final statusCode) => statusCode,
      _ => null,
    };
  }

  static bool _isExpiredOtp(Failure failure) {
    final int? status = _statusCode(failure);
    if (status == StatusCode.gone) {
      return true;
    }
    if (status != StatusCode.unProcessableContent) {
      return false;
    }
    if (_mentionsExpiry(failure.message)) {
      return true;
    }
    final List<String> codeMessages =
        failure.fieldErrors[_codeField] ?? const <String>[];
    return codeMessages.any(_mentionsExpiry);
  }

  static bool _mentionsExpiry(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }
    final String lower = text.toLowerCase();
    return _expiredMarkers.any(lower.contains);
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
}
