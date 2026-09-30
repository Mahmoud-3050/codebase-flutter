import 'package:equatable/equatable.dart';

import 'auth_session.dart';
import 'otp_challenge.dart';

sealed class LoginOutcome extends Equatable {
  const LoginOutcome();
}

final class LoginSucceeded extends LoginOutcome {
  const LoginSucceeded(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => <Object?>[session];
}

final class LoginNeedsEmailVerification extends LoginOutcome {
  const LoginNeedsEmailVerification(this.challenge);

  final OtpChallenge challenge;

  @override
  List<Object?> get props => <Object?>[challenge];
}
