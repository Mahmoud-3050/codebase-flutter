import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/usecases/change_student_password_usecase.dart';
import '../../../domain/entities/change_student_password_response.dart';

part 'change_student_password_states.dart';

class ChangeStudentPasswordCubit extends Cubit<ChangeStudentPasswordState>
    with CubitRequestCanceller<ChangeStudentPasswordState> {
  final ChangeStudentPasswordUseCase changeStudentPasswordUseCase;

  ChangeStudentPasswordCubit(this.changeStudentPasswordUseCase)
    : super(const ApiCallHolding<Null>());

  Future<void> fChangeStudentPassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    emit(const ApiCallLoading<Null>());
    final Either<Failure, ChangeStudentPasswordResponse> eitherResult =
        await changeStudentPasswordUseCase(
          ChangeStudentPasswordParams(
            oldPassword: oldPassword,
            newPassword: newPassword,
            newPasswordConfirmation: newPasswordConfirmation,
            cancellation: nextRequestCancelToken(),
          ),
        );
    eitherResult.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<Null>.fromFailure(
            failure,
            fallbackMessage: Strings.pleaseTryAgainLater,
          ),
        );
      },
      (ChangeStudentPasswordResponse response) {
        if (isClosed) {
          return;
        }
        emit(const ApiCallSuccess<Null>(data: null));
      },
    );
  }
}
