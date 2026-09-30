import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/registration_draft.dart';
import '../../../domain/usecases/read_registration_draft_usecase.dart';
import '../../auth_error_copy.dart';

part 'read_registration_draft_states.dart';

class ReadRegistrationDraftCubit extends Cubit<ReadRegistrationDraftState>
    with CubitRequestCanceller<ReadRegistrationDraftState> {
  ReadRegistrationDraftCubit(this.readRegistrationDraftUseCase)
    : super(const ApiCallHolding<RegistrationDraft?>());

  final ReadRegistrationDraftUseCase readRegistrationDraftUseCase;

  Future<void> fReadRegistrationDraft() async {
    emit(const ApiCallLoading<RegistrationDraft?>());
    final Either<Failure, RegistrationDraft?> result =
        await readRegistrationDraftUseCase(
          NoParams(cancellation: nextRequestCancelToken()),
        );
    result.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<RegistrationDraft?>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (RegistrationDraft? draft) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<RegistrationDraft?>(data: draft));
      },
    );
  }
}
