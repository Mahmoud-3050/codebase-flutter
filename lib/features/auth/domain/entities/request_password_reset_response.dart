import 'package:equatable/equatable.dart';

import 'otp_challenge.dart';

class RequestPasswordResetResponse extends Equatable {
  const RequestPasswordResetResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final OtpChallenge data;

  @override
  List<Object?> get props => <Object?>[status, message, data];
}
