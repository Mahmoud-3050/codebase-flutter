import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/otp_challenge.dart';
import '../../../domain/entities/register_response.dart';
import '../../../domain/usecases/register_usecase.dart';
import '../../auth_error_copy.dart';

part 'register_states.dart';

class RegisterCubit extends Cubit<RegisterState>
    with CubitRequestCanceller<RegisterState> {
  RegisterCubit(this.registerUseCase)
    : super(const ApiCallHolding<OtpChallenge>());

  final RegisterUseCase registerUseCase;

  Future<void> fRegister({
    required String fullName,
    required String email,
    required String dialingCode,
    required String phone,
    required String password,
    String? avatarPath,
  }) async {
    emit(const ApiCallLoading<OtpChallenge>());
    final Either<Failure, RegisterResponse> result = await registerUseCase(
      RegisterParams(
        fullName: fullName,
        email: email,
        dialingCode: dialingCode,
        phone: phone,
        password: password,
        avatarPath: avatarPath,
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
      (RegisterResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<OtpChallenge>(data: response.data));
      },
    );
  }
}
