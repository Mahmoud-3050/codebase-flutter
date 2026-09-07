import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_student_profile_usecase.dart';
import '../../../domain/entities/get_student_profile_response.dart';

part 'get_student_profile_states.dart';

class GetStudentProfileCubit extends Cubit<GetStudentProfileState>
    with CubitRequestCanceller<GetStudentProfileState> {
  final GetStudentProfileUseCase getStudentProfileUseCase;

  GetStudentProfileCubit(this.getStudentProfileUseCase)
    : super(const ApiCallHolding<Student>());

  Future<void> fGetStudentProfile() async {
    emit(const ApiCallLoading<Student>());
    final Either<Failure, GetStudentProfileResponse> eitherResult =
        await getStudentProfileUseCase(
          NoParams(cancellation: nextRequestCancelToken()),
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
      (GetStudentProfileResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<Student>(data: response.data));
      },
    );
  }
}
