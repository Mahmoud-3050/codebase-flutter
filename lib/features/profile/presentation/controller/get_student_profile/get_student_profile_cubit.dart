import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_student_profile_usecase.dart';
import '../../../domain/entities/get_student_profile_response.dart';

part 'get_student_profile_states.dart';

class GetStudentProfileCubit extends Cubit<GetStudentProfileState> {
  final GetStudentProfileUseCase getStudentProfileUseCase;

  GetStudentProfileCubit(this.getStudentProfileUseCase)
    : super(const GetStudentProfileInitialState());

  Future<void> fGetStudentProfile() async {
    emit(const GetStudentProfileLoadingState());
    final Either<Failure, GetStudentProfileResponse> eitherResult =
        await getStudentProfileUseCase(NoParams());
    eitherResult.fold(
      (Failure failure) {
        emit(
          GetStudentProfileErrorState(
            message: failure.message ?? Strings.pleaseTryAgainLater,
          ),
        );
      },
      (GetStudentProfileResponse response) {
        emit(GetStudentProfileSuccessState(data: response.data));
      },
    );
  }
}
