import 'package:equatable/equatable.dart';

import 'login_outcome.dart';

class LoginResponse extends Equatable {
  const LoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final LoginOutcome data;

  @override
  List<Object?> get props => <Object?>[status, message, data];
}
