import 'package:equatable/equatable.dart';

import 'auth_user.dart';

final class AuthSession extends Equatable {
  const AuthSession({required this.accessToken, required this.user});

  final String accessToken;
  final AuthUser user;

  @override
  List<Object?> get props => <Object?>[accessToken, user];
}
