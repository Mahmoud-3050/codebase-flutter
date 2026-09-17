import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/continue_as_guest_usecase.dart';
import '../../auth_error_copy.dart';

part 'guest_mode_states.dart';

class GuestModeCubit extends Cubit<GuestModeState>
    with CubitRequestCanceller<GuestModeState> {
  GuestModeCubit(this.continueAsGuestUseCase)
    : super(const ApiCallHolding<bool>());

  final ContinueAsGuestUseCase continueAsGuestUseCase;

  Future<void> fContinueAsGuest() async {
    emit(const ApiCallLoading<bool>());
    final Either<Failure, void> result = await continueAsGuestUseCase(
      NoParams(cancellation: nextRequestCancelToken()),
    );
    result.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<bool>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (_) {
        if (isClosed) {
          return;
        }
        emit(const ApiCallSuccess<bool>(data: true));
      },
    );
  }
}
