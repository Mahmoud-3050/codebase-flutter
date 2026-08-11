import 'package:equatable/equatable.dart';

class ChangeStudentPasswordResponse extends Equatable{
  final String status;
  final String message;

  const ChangeStudentPasswordResponse({
    required this.status,
    required this.message,
  });

  @override
  List<Object?> get props => <Object?>[
    status,
    message,
  ];
}



