import 'package:equatable/equatable.dart';

import 'auth_session.dart';
import 'registration_draft.dart';

sealed class AuthOutcome extends Equatable {
  const AuthOutcome();
}

final class AuthSessionEstablished extends AuthOutcome {
  const AuthSessionEstablished(this.session);

  final AuthSession session;

  @override
  List<Object?> get props => <Object?>[session];
}

final class AuthRegistrationRequired extends AuthOutcome {
  const AuthRegistrationRequired(this.draft);

  final RegistrationDraft draft;

  @override
  List<Object?> get props => <Object?>[draft];
}
