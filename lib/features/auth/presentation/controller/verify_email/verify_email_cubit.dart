import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/verify_email_response.dart';
import '../../../domain/usecases/verify_email_usecase.dart';
import '../../auth_error_copy.dart';

part 'verify_email_states.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState>
    with CubitRequestCanceller<VerifyEmailState> {
  VerifyEmailCubit(this.verifyEmailUseCase)
    : super(const ApiCallHolding<AuthSession>());

  final VerifyEmailUseCase verifyEmailUseCase;

  Future<void> fVerifyEmail({
    required String email,
    required String code,
  }) async {
    emit(const ApiCallLoading<AuthSession>());
    final Either<Failure, VerifyEmailResponse> result =
        await verifyEmailUseCase(
          VerifyEmailParams(
            email: email,
            code: code,
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
            message: AuthErrorCopy.of(failure, otp: true),
            fieldErrors: AuthErrorCopy.otpFieldErrors(failure),
          ),
        );
      },
      (VerifyEmailResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<AuthSession>(data: response.data));
      },
    );
  }
}
