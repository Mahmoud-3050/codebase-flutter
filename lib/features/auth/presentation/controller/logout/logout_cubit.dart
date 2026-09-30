import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import '../../auth_error_copy.dart';

part 'logout_states.dart';

class LogoutCubit extends Cubit<LogoutState>
    with CubitRequestCanceller<LogoutState> {
  LogoutCubit(this.logoutUseCase) : super(const ApiCallHolding<bool>());

  final LogoutUseCase logoutUseCase;

  Future<void> fLogout() async {
    emit(const ApiCallLoading<bool>());
    final Either<Failure, dynamic> result = await logoutUseCase(
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
