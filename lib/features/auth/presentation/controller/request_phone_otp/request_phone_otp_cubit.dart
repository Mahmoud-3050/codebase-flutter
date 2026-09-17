import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/otp_challenge.dart';
import '../../../domain/entities/request_otp_response.dart';
import '../../../domain/enums/otp_purpose.dart';
import '../../../domain/usecases/request_phone_otp_usecase.dart';
import '../../auth_error_copy.dart';

part 'request_phone_otp_states.dart';

class RequestPhoneOtpCubit extends Cubit<RequestPhoneOtpState>
    with CubitRequestCanceller<RequestPhoneOtpState> {
  RequestPhoneOtpCubit(this.requestPhoneOtpUseCase)
    : super(const ApiCallHolding<OtpChallenge>());

  final RequestPhoneOtpUseCase requestPhoneOtpUseCase;

  Future<void> fRequestPhoneOtp({
    required String dialingCode,
    required String phone,
    OtpPurpose purpose = OtpPurpose.phoneSignIn,
  }) async {
    emit(const ApiCallLoading<OtpChallenge>());
    final Either<Failure, RequestOtpResponse> result =
        await requestPhoneOtpUseCase(
          RequestPhoneOtpParams(
            dialingCode: dialingCode,
            phone: phone,
            purpose: purpose,
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
