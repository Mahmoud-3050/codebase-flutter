part of 'update_company_user_profile_cubit.dart';


sealed class UpdateCompanyUserProfileState extends Equatable {
  const UpdateCompanyUserProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

final class UpdateCompanyUserProfileInitialState extends UpdateCompanyUserProfileState {
  const UpdateCompanyUserProfileInitialState();
}

final class UpdateCompanyUserProfileLoadingState extends UpdateCompanyUserProfileState {
  const UpdateCompanyUserProfileLoadingState();
}

final class UpdateCompanyUserProfileSuccessState extends UpdateCompanyUserProfileState {
  final Company? data;

  const UpdateCompanyUserProfileSuccessState({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class UpdateCompanyUserProfileErrorState extends UpdateCompanyUserProfileState {
  final String message;

  const UpdateCompanyUserProfileErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

