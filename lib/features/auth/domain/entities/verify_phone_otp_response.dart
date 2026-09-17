import 'package:equatable/equatable.dart';

import 'auth_outcome.dart';

class VerifyPhoneOtpResponse extends Equatable {
  const VerifyPhoneOtpResponse({
    required this.status,
    required this.message,
    this.data,
  });

  final String status;
  final String message;
  final AuthOutcome? data;

  @override
  List<Object?> get props => <Object?>[status, message, data];
}
