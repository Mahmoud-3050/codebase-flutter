import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/auth_outcome.dart';
import '../../../domain/entities/verify_phone_otp_response.dart';
import '../../../domain/enums/otp_purpose.dart';
import '../../../domain/usecases/verify_phone_otp_usecase.dart';
import '../../auth_error_copy.dart';

part 'verify_phone_otp_states.dart';

class VerifyPhoneOtpCubit extends Cubit<VerifyPhoneOtpState>
    with CubitRequestCanceller<VerifyPhoneOtpState> {
  VerifyPhoneOtpCubit(this.verifyPhoneOtpUseCase)
    : super(const ApiCallHolding<AuthOutcome?>());

  final VerifyPhoneOtpUseCase verifyPhoneOtpUseCase;

  Future<void> fVerifyPhoneOtp({
    required String dialingCode,
    required String phone,
    required String code,
    required OtpPurpose purpose,
  }) async {
    emit(const ApiCallLoading<AuthOutcome?>());
    final Either<Failure, VerifyPhoneOtpResponse> result =
        await verifyPhoneOtpUseCase(
          VerifyPhoneOtpParams(
            dialingCode: dialingCode,
            phone: phone,
            code: code,
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
          ApiCallError<AuthOutcome?>(
            message: AuthErrorCopy.of(failure, otp: true),
            fieldErrors: AuthErrorCopy.otpFieldErrors(failure),
          ),
        );
      },
      (VerifyPhoneOtpResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<AuthOutcome?>(data: response.data));
      },
    );
  }
}
