import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/utils/values/strings.dart';
import '../../../domain/usecases/change_student_password_usecase.dart';
import '../../../domain/entities/change_student_password_response.dart';

part 'change_student_password_states.dart';

class ChangeStudentPasswordCubit extends Cubit<ChangeStudentPasswordState> {
  final ChangeStudentPasswordUseCase changeStudentPasswordUseCase;

  ChangeStudentPasswordCubit(this.changeStudentPasswordUseCase) : super(const ChangeStudentPasswordInitialState());


  Future<void> fChangeStudentPassword({
   required String oldPassword,
   required String newPassword,
   required String newPasswordConfirmation,
  }) async {
    emit(const ChangeStudentPasswordLoadingState());
    final Either<Failure, ChangeStudentPasswordResponse> eitherResult = await changeStudentPasswordUseCase(ChangeStudentPasswordParams(
      oldPassword: oldPassword,
      newPassword: newPassword,
      newPasswordConfirmation: newPasswordConfirmation,
    ));
    eitherResult.fold((Failure failure) {
      emit(ChangeStudentPasswordErrorState(message: failure.message?? Strings.pleaseTryAgainLater));
    }, (ChangeStudentPasswordResponse response) {
      emit(const ChangeStudentPasswordSuccessState());
    });
  }
}

