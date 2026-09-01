import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/usecases/get_company_profile_usecase.dart';
import '../../../domain/entities/get_company_profile_response.dart';

part 'get_company_profile_states.dart';

class GetCompanyProfileCubit extends Cubit<GetCompanyProfileState> {
  final GetCompanyProfileUseCase getCompanyProfileUseCase;

  GetCompanyProfileCubit(this.getCompanyProfileUseCase)
    : super(const GetCompanyProfileInitialState());

  Future<void> fGetCompanyProfile() async {
    emit(const GetCompanyProfileLoadingState());
    final Either<Failure, GetCompanyProfileResponse> eitherResult =
        await getCompanyProfileUseCase(NoParams());
    eitherResult.fold(
      (Failure failure) {
        emit(
          GetCompanyProfileErrorState(
            message: failure.message ?? Strings.pleaseTryAgainLater,
          ),
        );
      },
      (GetCompanyProfileResponse response) {
        emit(GetCompanyProfileSuccessState(data: response.data));
      },
    );
  }
}
