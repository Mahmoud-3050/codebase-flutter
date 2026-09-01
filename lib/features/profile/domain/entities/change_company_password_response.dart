import 'package:equatable/equatable.dart';

class ChangeCompanyPasswordResponse extends Equatable {
  final String status;
  final String message;

  const ChangeCompanyPasswordResponse({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => <Object?>[status, message];
}
