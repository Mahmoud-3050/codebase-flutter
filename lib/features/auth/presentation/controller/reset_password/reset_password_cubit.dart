import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/reset_password_response.dart';
import '../../../domain/usecases/reset_password_usecase.dart';
import '../../auth_error_copy.dart';

part 'reset_password_states.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState>
    with CubitRequestCanceller<ResetPasswordState> {
  ResetPasswordCubit(this.resetPasswordUseCase)
    : super(const ApiCallHolding<AuthSession>());

  final ResetPasswordUseCase resetPasswordUseCase;

  Future<void> fResetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    emit(const ApiCallLoading<AuthSession>());
    final Either<Failure, ResetPasswordResponse> result =
        await resetPasswordUseCase(
          ResetPasswordParams(
            email: email,
            code: code,
            password: password,
            cancellation: nextRequestCancelToken(),
          ),
        );
    result.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<AuthSession>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (ResetPasswordResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<AuthSession>(data: response.data));
      },
    );
  }
}
