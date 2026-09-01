part of 'change_student_password_cubit.dart';

sealed class ChangeStudentPasswordState extends Equatable {
  const ChangeStudentPasswordState();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChangeStudentPasswordInitialState
    extends ChangeStudentPasswordState {
  const ChangeStudentPasswordInitialState();
}

final class ChangeStudentPasswordLoadingState
    extends ChangeStudentPasswordState {
  const ChangeStudentPasswordLoadingState();
}

final class ChangeStudentPasswordSuccessState
    extends ChangeStudentPasswordState {
  const ChangeStudentPasswordSuccessState();
}

final class ChangeStudentPasswordErrorState extends ChangeStudentPasswordState {
  final String message;

  const ChangeStudentPasswordErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}
