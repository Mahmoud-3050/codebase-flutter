import 'package:equatable/equatable.dart';

import '../enums/otp_purpose.dart';

final class OtpChallenge extends Equatable {
  const OtpChallenge({
    required this.purpose,
    required this.maskedDestination,
    required this.expiresInSeconds,
    required this.resendAvailableInSeconds,
  });

  final OtpPurpose purpose;
  final String maskedDestination;
  final int expiresInSeconds;
  final int resendAvailableInSeconds;

  @override
  List<Object?> get props => <Object?>[
    purpose,
    maskedDestination,
    expiresInSeconds,
    resendAvailableInSeconds,
  ];
}
