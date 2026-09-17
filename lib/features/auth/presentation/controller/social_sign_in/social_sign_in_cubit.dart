import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/entities/auth_outcome.dart';
import '../../../domain/entities/social_sign_in_response.dart';
import '../../../domain/enums/social_provider.dart';
import '../../../domain/usecases/social_sign_in_usecase.dart';
import '../../auth_error_copy.dart';

part 'social_sign_in_states.dart';

class SocialSignInCubit extends Cubit<SocialSignInState>
    with CubitRequestCanceller<SocialSignInState> {
  SocialSignInCubit(this.socialSignInUseCase)
    : super(const ApiCallHolding<AuthOutcome>());

  final SocialSignInUseCase socialSignInUseCase;

  Future<void> fSocialSignIn(SocialProvider provider) async {
    emit(const ApiCallLoading<AuthOutcome>());
    final Either<Failure, SocialSignInResponse> result =
        await socialSignInUseCase(
          SocialSignInParams(
            provider: provider,
            cancellation: nextRequestCancelToken(),
          ),
        );
    result.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        if (failure is SocialSignInCancelledFailure) {
          emit(const ApiCallHolding<AuthOutcome>());
          return;
        }
        emit(
          ApiCallError<AuthOutcome>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (SocialSignInResponse response) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<AuthOutcome>(data: response.data));
      },
    );
  }
}
