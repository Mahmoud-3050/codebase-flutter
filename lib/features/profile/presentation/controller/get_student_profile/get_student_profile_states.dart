part of 'get_student_profile_cubit.dart';


sealed class GetStudentProfileState extends Equatable {
  const GetStudentProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

final class GetStudentProfileInitialState extends GetStudentProfileState {
  const GetStudentProfileInitialState();
}

final class GetStudentProfileLoadingState extends GetStudentProfileState {
  const GetStudentProfileLoadingState();
}

final class GetStudentProfileSuccessState extends GetStudentProfileState {
  final Student? data;

  const GetStudentProfileSuccessState({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class GetStudentProfileErrorState extends GetStudentProfileState {
  final String message;

  const GetStudentProfileErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

