import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/usecases/change_company_password_usecase.dart';
import '../../../domain/entities/change_company_password_response.dart';

part 'change_company_password_states.dart';

class ChangeCompanyPasswordCubit extends Cubit<ChangeCompanyPasswordState>
    with CubitRequestCanceller<ChangeCompanyPasswordState> {
  final ChangeCompanyPasswordUseCase changeCompanyPasswordUseCase;

  ChangeCompanyPasswordCubit(this.changeCompanyPasswordUseCase)
    : super(const ChangeCompanyPasswordInitialState());

  Future<void> fChangeCompanyPassword({
    required String oldPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    emit(const ChangeCompanyPasswordLoadingState());
    final Either<Failure, ChangeCompanyPasswordResponse> eitherResult =
        await changeCompanyPasswordUseCase(
          ChangeCompanyPasswordParams(
            oldPassword: oldPassword,
            newPassword: newPassword,
            newPasswordConfirmation: newPasswordConfirmation,
            cancellation: nextRequestCancelToken(),
          ),
        );
    eitherResult.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          ChangeCompanyPasswordErrorState(
            message: failure.message ?? Strings.pleaseTryAgainLater,
          ),
        );
      },
      (ChangeCompanyPasswordResponse response) {
        if (isClosed) {
          return;
        }
        emit(const ChangeCompanyPasswordSuccessState());
      },
    );
  }
}
