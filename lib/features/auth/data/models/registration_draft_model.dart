import 'dart:convert';

import '../../domain/entities/registration_draft.dart';
import '../../domain/enums/registration_source.dart';

class RegistrationDraftModel extends RegistrationDraft {
  const RegistrationDraftModel({
    required super.registrationToken,
    required super.source,
    super.verifiedEmail,
    super.verifiedDialingCode,
    super.verifiedPhone,
    super.suggestedFullName,
  });

  factory RegistrationDraftModel.fromEntity(RegistrationDraft draft) {
    return RegistrationDraftModel(
      registrationToken: draft.registrationToken,
      source: draft.source,
      verifiedEmail: draft.verifiedEmail,
      verifiedDialingCode: draft.verifiedDialingCode,
      verifiedPhone: draft.verifiedPhone,
      suggestedFullName: draft.suggestedFullName,
    );
  }

  factory RegistrationDraftModel.fromJson(Map<String, dynamic> json) {
    return RegistrationDraftModel(
      registrationToken: json['registration_token']?.toString() ?? '',
      source: RegistrationSource.fromWireName(
        json['source']?.toString() ?? 'phone',
      ),
      verifiedEmail: json['verified_email']?.toString(),
      verifiedDialingCode: json['verified_dialing_code']?.toString(),
      verifiedPhone: json['verified_phone']?.toString(),
      suggestedFullName: json['suggested_full_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'registration_token': registrationToken,
      'source': source.wireName,
      if (verifiedEmail != null) 'verified_email': verifiedEmail,
      if (verifiedDialingCode != null)
        'verified_dialing_code': verifiedDialingCode,
      if (verifiedPhone != null) 'verified_phone': verifiedPhone,
      if (suggestedFullName != null) 'suggested_full_name': suggestedFullName,
    };
  }

  String encode() => jsonEncode(toJson());

  static RegistrationDraftModel decode(String raw) {
    return RegistrationDraftModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }
}
