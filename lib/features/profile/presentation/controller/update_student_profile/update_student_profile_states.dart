part of 'update_student_profile_cubit.dart';


sealed class UpdateStudentProfileState extends Equatable {
  const UpdateStudentProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

final class UpdateStudentProfileInitialState extends UpdateStudentProfileState {
  const UpdateStudentProfileInitialState();
}

final class UpdateStudentProfileLoadingState extends UpdateStudentProfileState {
  const UpdateStudentProfileLoadingState();
}

final class UpdateStudentProfileSuccessState extends UpdateStudentProfileState {
  final Student? data;

  const UpdateStudentProfileSuccessState({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class UpdateStudentProfileErrorState extends UpdateStudentProfileState {
  final String message;

  const UpdateStudentProfileErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

