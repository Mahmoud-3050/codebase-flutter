part of 'update_company_profile_cubit.dart';


sealed class UpdateCompanyProfileState extends Equatable {
  const UpdateCompanyProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

final class UpdateCompanyProfileInitialState extends UpdateCompanyProfileState {
  const UpdateCompanyProfileInitialState();
}

final class UpdateCompanyProfileLoadingState extends UpdateCompanyProfileState {
  const UpdateCompanyProfileLoadingState();
}

final class UpdateCompanyProfileSuccessState extends UpdateCompanyProfileState {
  final Company? data;

  const UpdateCompanyProfileSuccessState({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class UpdateCompanyProfileErrorState extends UpdateCompanyProfileState {
  final String message;

  const UpdateCompanyProfileErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

