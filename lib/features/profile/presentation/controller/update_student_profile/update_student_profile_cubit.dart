import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/values/strings.dart';
import '../../../domain/usecases/update_student_profile_usecase.dart';
import '../../../domain/entities/update_student_profile_response.dart';

part 'update_student_profile_states.dart';

class UpdateStudentProfileCubit extends Cubit<UpdateStudentProfileState> {
  final UpdateStudentProfileUseCase updateStudentProfileUseCase;

  UpdateStudentProfileCubit(this.updateStudentProfileUseCase) : super(const UpdateStudentProfileInitialState());


  Future<void> fUpdateStudentProfile({
   required String firstName,
   required String secondName,
   required String lastName,
   required String dialingCode,
   required String phone,
   required int cityId,
   required String birthdate,
   required String image,
   required String institute,
   required int degreeId,
   required int majorId,
   required String graduationDate,
   required String gpaFile,
   required String cvFile,
  }) async {
    emit(const UpdateStudentProfileLoadingState());
    final Either<Failure, UpdateStudentProfileResponse> eitherResult = await updateStudentProfileUseCase(UpdateStudentProfileParams(
      firstName: firstName,
      secondName: secondName,
      lastName: lastName,
      dialingCode: dialingCode,
      phone: phone,
      cityId: cityId,
      birthdate: birthdate,
      image: image,
      institute: institute,
      degreeId: degreeId,
      majorId: majorId,
      graduationDate: graduationDate,
      gpaFile: gpaFile,
      cvFile: cvFile,
    ));
    eitherResult.fold((Failure failure) {
      emit(UpdateStudentProfileErrorState(message: failure.message?? Strings.pleaseTryAgainLater));
    }, (UpdateStudentProfileResponse response) {
      emit(UpdateStudentProfileSuccessState(data: response.data));
    });
  }
}

