import 'package:equatable/equatable.dart';

import 'auth_session.dart';

class VerifyEmailResponse extends Equatable {
  const VerifyEmailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final AuthSession data;

  @override
  List<Object?> get props => <Object?>[status, message, data];
}
