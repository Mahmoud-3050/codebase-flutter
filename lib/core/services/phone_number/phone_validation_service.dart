import 'dart:developer';

import 'package:phone_numbers_parser/phone_numbers_parser.dart';

class PhoneValidationService {
  static final PhoneValidationService _instance = PhoneValidationService._internal();

  factory PhoneValidationService() {
    return _instance;
  }

  PhoneValidationService._internal();

  PhoneValidationResult validatePhoneNumber({
    required String phoneNumber,
    required String phoneCode,
  }) {
    try {
      PhoneNumber parsedNumber = PhoneNumber.parse('$phoneCode$phoneNumber');
      bool isValid = parsedNumber.isValid(type: PhoneNumberType.mobile);
      if(!isValid){
        throw Exception('Phone($phoneCode$phoneNumber) is not valid!');
      }
      String phoneNumberParsed = parsedNumber.nsn;
      String phoneCodeParsed = parsedNumber.countryCode;
      return PhoneValidationResult(
        isValidPhone: isValid,
        phoneNumber: phoneNumberParsed,
        phoneCode: phoneCodeParsed,
        fullNumber: '+$phoneCodeParsed$phoneNumberParsed',
      );
    } catch (e) {
      log('@PhoneValidationService.validatePhoneNumber: ERROR|${e.toString()}');
      return PhoneValidationResult(
        isValidPhone: false,
        phoneNumber: phoneNumber,
        phoneCode: phoneCode,
        fullNumber: '+$phoneCode$phoneNumber',
      );
    }
  }
}

class PhoneValidationResult {
  final bool isValidPhone;
  final String phoneNumber;
  final String phoneCode;
  final String fullNumber;

  const PhoneValidationResult({
    required this.isValidPhone,
    required this.phoneNumber,
    required this.phoneCode,
    required this.fullNumber,
  });

  @override
  String toString() {
    return 'PhoneValidationResult(isValidPhone: $isValidPhone, phoneNumber: $phoneNumber, phoneCode: $phoneCode, fullNumber: $fullNumber)';
  }
}