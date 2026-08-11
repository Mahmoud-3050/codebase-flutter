part of 'get_company_profile_cubit.dart';


sealed class GetCompanyProfileState extends Equatable {
  const GetCompanyProfileState();

  @override
  List<Object?> get props => <Object?>[];
}

final class GetCompanyProfileInitialState extends GetCompanyProfileState {
  const GetCompanyProfileInitialState();
}

final class GetCompanyProfileLoadingState extends GetCompanyProfileState {
  const GetCompanyProfileLoadingState();
}

final class GetCompanyProfileSuccessState extends GetCompanyProfileState {
  final Company? data;

  const GetCompanyProfileSuccessState({required this.data});

  @override
  List<Object?> get props => <Object?>[data];
}

final class GetCompanyProfileErrorState extends GetCompanyProfileState {
  final String message;

  const GetCompanyProfileErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}

