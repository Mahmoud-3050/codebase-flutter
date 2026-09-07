import 'package:flutter_test/flutter_test.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import 'package:codebase/core/services/phone_number/phone_validation_service.dart';

void main() {
  final PhoneValidationService service = PhoneValidationService();

  group('isoCodeFromDialingCode', () {
    test('maps +966 and 966 to Saudi Arabia', () {
      expect(service.isoCodeFromDialingCode('+966'), IsoCode.SA);
      expect(service.isoCodeFromDialingCode('966'), IsoCode.SA);
    });

    test('falls back for empty or unknown codes', () {
      expect(service.isoCodeFromDialingCode(''), IsoCode.SA);
      expect(
        service.isoCodeFromDialingCode('not-a-code', fallback: .EG),
        IsoCode.EG,
      );
    });
  });

  group('formatDialingCode', () {
    test('returns API dialing_code form', () {
      expect(service.formatDialingCode(.SA), '+966');
      expect(service.formatDialingCode(.EG), '+20');
    });
  });

  group('validatePhoneNumber', () {
    test('accepts a valid Saudi mobile with +966', () {
      final PhoneValidationResult result = service.validatePhoneNumber(
        phoneNumber: '501234567',
        phoneCode: '+966',
      );

      expect(result.isValidPhone, isTrue);
      expect(result.phoneCode, '966');
      expect(result.phoneNumber, '501234567');
      expect(result.fullNumber, '+966501234567');
    });

    test('rejects an invalid national number', () {
      final PhoneValidationResult result = service.validatePhoneNumber(
        phoneNumber: '12',
        phoneCode: '+966',
      );

      expect(result.isValidPhone, isFalse);
    });
  });
}
