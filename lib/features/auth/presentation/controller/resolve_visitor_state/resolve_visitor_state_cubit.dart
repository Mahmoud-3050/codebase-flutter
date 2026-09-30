import 'package:either/either.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../../../core/utils/enums.dart';
import '../../../domain/usecases/resolve_visitor_state_usecase.dart';
import '../../auth_error_copy.dart';

part 'resolve_visitor_state_states.dart';

class ResolveVisitorStateCubit extends Cubit<ResolveVisitorStateState>
    with CubitRequestCanceller<ResolveVisitorStateState> {
  ResolveVisitorStateCubit(this.resolveVisitorStateUseCase)
    : super(const ApiCallHolding<UserType>());

  final ResolveVisitorStateUseCase resolveVisitorStateUseCase;

  Future<void> fResolveVisitorState() async {
    emit(const ApiCallLoading<UserType>());
    final Either<Failure, UserType> result = await resolveVisitorStateUseCase(
      NoParams(cancellation: nextRequestCancelToken()),
    );
    result.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ApiCallError<UserType>(
            message: AuthErrorCopy.of(failure),
            fieldErrors: failure.fieldErrors,
          ),
        );
      },
      (UserType data) {
        if (isClosed) {
          return;
        }
        emit(ApiCallSuccess<UserType>(data: data));
      },
    );
  }
}
