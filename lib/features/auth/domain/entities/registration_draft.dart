import 'package:equatable/equatable.dart';

import '../enums/registration_source.dart';

class RegistrationDraft extends Equatable {
  const RegistrationDraft({
    required this.registrationToken,
    required this.source,
    this.verifiedEmail,
    this.verifiedDialingCode,
    this.verifiedPhone,
    this.suggestedFullName,
  });

  final String registrationToken;
  final RegistrationSource source;
  final String? verifiedEmail;
  final String? verifiedDialingCode;
  final String? verifiedPhone;
  final String? suggestedFullName;

  @override
  List<Object?> get props => <Object?>[
    registrationToken,
    source,
    verifiedEmail,
    verifiedDialingCode,
    verifiedPhone,
    suggestedFullName,
  ];
}
