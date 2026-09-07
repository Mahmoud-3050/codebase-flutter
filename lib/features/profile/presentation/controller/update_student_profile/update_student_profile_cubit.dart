import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/usecases/update_student_profile_usecase.dart';
import '../../../domain/entities/update_student_profile_response.dart';

part 'update_student_profile_states.dart';

class UpdateStudentProfileCubit extends Cubit<UpdateStudentProfileState>
    with CubitRequestCanceller<UpdateStudentProfileState> {
  final UpdateStudentProfileUseCase updateStudentProfileUseCase;

  UpdateStudentProfileCubit(this.updateStudentProfileUseCase)
    : super(const ApiCallHolding<Student>());

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
    emit(const ApiCallLoading<Student>());
    final Either<Failure, UpdateStudentProfileResponse> eitherResult =
        await updateStudentProfileUseCase(
          UpdateStudentProfileParams(
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
            cancellation: nextRequestCancelToken(),
          ),
        );
    eitherResult.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<Student>.fromFailure(
            failure,
            fallbackMessage: Strings.pleaseTryAgainLater,
          ),
        );
      },
      (UpdateStudentProfileResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<Student>(data: response.data));
      },
    );
  }
}
