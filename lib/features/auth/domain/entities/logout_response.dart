import 'package:equatable/equatable.dart';

class LogoutResponse extends Equatable {
  const LogoutResponse({required this.status, required this.message});

  final String status;
  final String message;

  @override
  List<Object?> get props => <Object?>[status, message];
}
