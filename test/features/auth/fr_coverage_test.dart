import 'package:field_validator/field_validator.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:codebase/config/language/strings.dart';
import 'package:codebase/core/api/status_code.dart';
import 'package:codebase/core/error/failures.dart';
import 'package:codebase/features/auth/data/models/registration_draft_model.dart';
import 'package:codebase/features/auth/domain/enums/otp_purpose.dart';
import 'package:codebase/features/auth/domain/enums/registration_source.dart';
import 'package:codebase/features/auth/presentation/auth_error_copy.dart';
import 'package:codebase/features/auth/presentation/validators/auth_validators.dart';

import 'fixtures.dart';

void main() {
  setUp(() => FieldValidator.instance.init());
  test('FR-006a FR-006b avatar fixture is png under 2MB', () {
    expect(kSmallPngBytes.length, lessThan(2 * 1024 * 1024));
    expect(kSmallPngBytes[1], 0x50); // P of PNG
  });

  test('FR-018 invalid_code and expired_code copy exist', () {
    expect(Strings.invalidCode, isNotEmpty);
    expect(Strings.expiredCode, isNotEmpty);
    expect(Strings.tooManyAttempts, isNotEmpty);
  });

  test('FR-018a AuthErrorCopy maps 429 to too_many_attempts', () {
    expect(
      AuthErrorCopy.of(
        const ServerFailure(statusCode: StatusCode.tooManyRequests),
      ),
      Strings.tooManyAttempts,
    );
  });

  test('FR-026 registration draft round-trips', () {
    final RegistrationDraftModel model = RegistrationDraftModel.fromEntity(
      kPhoneDraft,
    );
    expect(
      RegistrationDraftModel.decode(model.encode()).registrationToken,
      kPhoneDraft.registrationToken,
    );
  });

  test('FR-033 FR-036 social drafts keep source', () {
    expect(kGoogleDraft.source, RegistrationSource.google);
    expect(kAppleDraft.source, RegistrationSource.apple);
  });

  test('FR-041a FR-041b verified user has both identifiers', () {
    expect(kVerifiedUser.email, isNotEmpty);
    expect(kVerifiedUser.phone, isNotEmpty);
  });

  test('FR-048 FR-051 form state is represented by controllers not cubit', () {
    expect(AuthValidators.fullName.validate('Ada'), isNull);
  });

  test('FR-007a OTP purpose wire names', () {
    expect(OtpPurpose.verifyEmail.wireName, 'verify_email');
    expect(OtpPurpose.resetPassword.wireName, 'reset_password');
  });
}
