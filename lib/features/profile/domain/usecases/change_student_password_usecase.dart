import 'package:equatable/equatable.dart';
import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/change_student_password_response.dart';
import '../repositories/profile_repo.dart';

class ChangeStudentPasswordUseCase
    extends
        UseCase<ChangeStudentPasswordResponse, ChangeStudentPasswordParams> {
  final ProfileRepository repository;

  ChangeStudentPasswordUseCase({required this.repository});

  @override
  Future<Either<Failure, ChangeStudentPasswordResponse>> call(
    ChangeStudentPasswordParams params,
  ) async {
    return await repository.changeStudentPassword(params: params);
  }
}

class ChangeStudentPasswordParams extends Equatable {
  final String? oldPassword;
  final String? newPassword;
  final String? newPasswordConfirmation;
  final Object? cancellation;

  const ChangeStudentPasswordParams({
    required this.oldPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
    this.cancellation,
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
