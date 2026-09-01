part of 'change_company_password_cubit.dart';

sealed class ChangeCompanyPasswordState extends Equatable {
  const ChangeCompanyPasswordState();

  @override
  List<Object?> get props => <Object?>[];
}

final class ChangeCompanyPasswordInitialState
    extends ChangeCompanyPasswordState {
  const ChangeCompanyPasswordInitialState();
}

final class ChangeCompanyPasswordLoadingState
    extends ChangeCompanyPasswordState {
  const ChangeCompanyPasswordLoadingState();
}

final class ChangeCompanyPasswordSuccessState
    extends ChangeCompanyPasswordState {
  const ChangeCompanyPasswordSuccessState();
}

final class ChangeCompanyPasswordErrorState extends ChangeCompanyPasswordState {
  final String message;

  const ChangeCompanyPasswordErrorState({required this.message});

  @override
  List<Object?> get props => <Object?>[message];
}
