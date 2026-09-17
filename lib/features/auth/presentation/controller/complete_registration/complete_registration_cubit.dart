import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/auth_session.dart';
import '../../../domain/entities/complete_registration_response.dart';
import '../../../domain/enums/registration_source.dart';
import '../../../domain/usecases/complete_registration_usecase.dart';
import '../../auth_error_copy.dart';

part 'complete_registration_states.dart';

class CompleteRegistrationCubit extends Cubit<CompleteRegistrationState>
    with CubitRequestCanceller<CompleteRegistrationState> {
  CompleteRegistrationCubit(this.completeRegistrationUseCase)
    : super(const ApiCallHolding<AuthSession>());

  final CompleteRegistrationUseCase completeRegistrationUseCase;

  Future<void> fCompleteRegistration({
    required String registrationToken,
    required RegistrationSource source,
    required String fullName,
    required String password,
    String? email,
    String? dialingCode,
    String? phone,
    String? avatarPath,
  }) async {
    emit(const ApiCallLoading<AuthSession>());
    final Either<Failure, CompleteRegistrationResponse> result =
        await completeRegistrationUseCase(
          CompleteRegistrationParams(
            registrationToken: registrationToken,
            source: source,
            fullName: fullName,
            password: password,
            email: email,
            dialingCode: dialingCode,
            phone: phone,
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
          ApiCallError<AuthSession>(
            message: AuthErrorCopy.of(failure, draftConflict: true),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (CompleteRegistrationResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<AuthSession>(data: response.data));
      },
    );
  }
}
