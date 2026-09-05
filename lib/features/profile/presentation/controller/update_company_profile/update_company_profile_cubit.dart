import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/presentation/cubit_request_canceller.dart';
import '../../../domain/usecases/update_company_profile_usecase.dart';
import '../../../domain/entities/update_company_profile_response.dart';

part 'update_company_profile_states.dart';

class UpdateCompanyProfileCubit extends Cubit<UpdateCompanyProfileState>
    with CubitRequestCanceller<UpdateCompanyProfileState> {
  final UpdateCompanyProfileUseCase updateCompanyProfileUseCase;

  UpdateCompanyProfileCubit(this.updateCompanyProfileUseCase)
    : super(const UpdateCompanyProfileInitialState());

  Future<void> fUpdateCompanyProfile({
    required String companyName,
    required String industry,
    required String about,
    required String logo,
    required String description,
  }) async {
    emit(const UpdateCompanyProfileLoadingState());
    final Either<Failure, UpdateCompanyProfileResponse> eitherResult =
        await updateCompanyProfileUseCase(
          UpdateCompanyProfileParams(
            companyName: companyName,
            industry: industry,
            about: about,
            logo: logo,
            description: description,
            cancellation: nextRequestCancelToken(),
          ),
        );
    eitherResult.fold(
      (Failure failure) {
        if (shouldIgnoreFailure(failure)) {
          return;
        }
        emit(
          UpdateCompanyProfileErrorState(
            message: failure.message ?? Strings.pleaseTryAgainLater,
          ),
        );
      },
      (UpdateCompanyProfileResponse response) {
        if (isClosed) {
          return;
        }
        emit(UpdateCompanyProfileSuccessState(data: response.data));
      },
    );
  }
}
