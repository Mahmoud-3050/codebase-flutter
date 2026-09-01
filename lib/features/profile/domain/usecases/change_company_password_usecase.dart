import 'package:equatable/equatable.dart';
import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/change_company_password_response.dart';
import '../repositories/profile_repo.dart';

class ChangeCompanyPasswordUseCase
    extends
        UseCase<ChangeCompanyPasswordResponse, ChangeCompanyPasswordParams> {
  final ProfileRepository repository;

  ChangeCompanyPasswordUseCase({required this.repository});

  @override
  Future<Either<Failure, ChangeCompanyPasswordResponse>> call(
    ChangeCompanyPasswordParams params,
  ) async {
    return await repository.changeCompanyPassword(params: params);
  }
}

class ChangeCompanyPasswordParams extends Equatable {
  final String? oldPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;

  const ChangeCompanyPasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = {};
    if (oldPassword != null) {
      map['old_password'] = oldPassword;
    }
    if (newPassword != null) {
      map['new_password'] = newPassword;
    }
    if (newPasswordConfirmation != null) {
      map['new_password_confirmation'] = newPasswordConfirmation;
    }
    return map;
  }

  @override
  List<Object?> get props => <Object?>[
    oldPassword,
    newPassword,
    newPasswordConfirmation,
  ];
}
