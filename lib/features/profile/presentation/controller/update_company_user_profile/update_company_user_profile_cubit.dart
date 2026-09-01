import 'package:either/either.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/failures.dart';
import '../../../../../config/language/strings.dart';
import '../../../domain/usecases/update_company_user_profile_usecase.dart';
import '../../../domain/entities/update_company_user_profile_response.dart';

part 'update_company_user_profile_states.dart';

class UpdateCompanyUserProfileCubit
    extends Cubit<UpdateCompanyUserProfileState> {
  final UpdateCompanyUserProfileUseCase updateCompanyUserProfileUseCase;

  UpdateCompanyUserProfileCubit(this.updateCompanyUserProfileUseCase)
    : super(const UpdateCompanyUserProfileInitialState());

  Future<void> fUpdateCompanyUserProfile({
    required String firstName,
    required String secondName,
    required String lastName,
    required String fullName,
    required String dialingCode,
    required String phone,
    required String birthdate,
    required int cityId,
    required String image,
  }) async {
    emit(const UpdateCompanyUserProfileLoadingState());
    final Either<Failure, UpdateCompanyUserProfileResponse> eitherResult =
        await updateCompanyUserProfileUseCase(
          UpdateCompanyUserProfileParams(
            firstName: firstName,
            secondName: secondName,
            lastName: lastName,
            fullName: fullName,
            dialingCode: dialingCode,
            phone: phone,
            birthdate: birthdate,
            cityId: cityId,
            image: image,
          ),
        );
    eitherResult.fold(
      (Failure failure) {
        emit(
          UpdateCompanyUserProfileErrorState(
            message: failure.message ?? Strings.pleaseTryAgainLater,
          ),
        );
      },
      (UpdateCompanyUserProfileResponse response) {
        emit(UpdateCompanyUserProfileSuccessState(data: response.data));
      },
    );
  }
}
