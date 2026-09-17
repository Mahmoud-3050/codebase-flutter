import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/otp_challenge.dart';
import '../../../domain/entities/request_otp_response.dart';
import '../../../domain/usecases/request_email_otp_usecase.dart';
import '../../auth_error_copy.dart';

part 'request_email_otp_states.dart';

class RequestEmailOtpCubit extends Cubit<RequestEmailOtpState>
    with CubitRequestCanceller<RequestEmailOtpState> {
  RequestEmailOtpCubit(this.requestEmailOtpUseCase)
    : super(const ApiCallHolding<OtpChallenge>());

  final RequestEmailOtpUseCase requestEmailOtpUseCase;

  Future<void> fRequestEmailOtp({required String email}) async {
    emit(const ApiCallLoading<OtpChallenge>());
    final Either<Failure, RequestOtpResponse> result =
        await requestEmailOtpUseCase(
          RequestEmailOtpParams(
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
      (RequestOtpResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<OtpChallenge>(data: response.data));
      },
    );
  }
}
