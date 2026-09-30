import 'package:equatable/equatable.dart';

import 'auth_outcome.dart';

class SocialSignInResponse extends Equatable {
  const SocialSignInResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  final String status;
  final String message;
  final AuthOutcome data;

  @override
  List<Object?> get props => <Object?>[status, message, data];
}
