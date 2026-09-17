import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/login_outcome.dart';
import '../../../domain/entities/login_response.dart';
import '../../../domain/usecases/login_usecase.dart';
import '../../auth_error_copy.dart';

part 'login_states.dart';

class LoginCubit extends Cubit<LoginState>
    with CubitRequestCanceller<LoginState> {
  LoginCubit(this.loginUseCase) : super(const ApiCallHolding<LoginOutcome>());

  final LoginUseCase loginUseCase;

  Future<void> fLogin({required String email, required String password}) async {
    emit(const ApiCallLoading<LoginOutcome>());
    final Either<Failure, LoginResponse> result = await loginUseCase(
      LoginParams(
        email: email,
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
          ApiCallError<LoginOutcome>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (LoginResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<LoginOutcome>(data: response.data));
      },
    );
  }
}
