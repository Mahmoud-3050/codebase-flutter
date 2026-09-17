import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/otp_challenge.dart';
import '../../../domain/entities/request_password_reset_response.dart';
import '../../../domain/usecases/request_password_reset_usecase.dart';
import '../../auth_error_copy.dart';

part 'request_password_reset_states.dart';

class RequestPasswordResetCubit extends Cubit<RequestPasswordResetState>
    with CubitRequestCanceller<RequestPasswordResetState> {
  RequestPasswordResetCubit(this.requestPasswordResetUseCase)
    : super(const ApiCallHolding<OtpChallenge>());

  final RequestPasswordResetUseCase requestPasswordResetUseCase;

  Future<void> fRequestPasswordReset({required String email}) async {
    emit(const ApiCallLoading<OtpChallenge>());
    final Either<Failure, RequestPasswordResetResponse> result =
        await requestPasswordResetUseCase(
          RequestPasswordResetParams(
            email: email,
            cancellation: nextRequestCancelToken(),
          ),
        );
    result.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<OtpChallenge>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (RequestPasswordResetResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<OtpChallenge>(data: response.data));
      },
    );
  }
}
