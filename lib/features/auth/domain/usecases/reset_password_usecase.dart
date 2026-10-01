import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/reset_password_response.dart';
import '../repositories/auth_repo.dart';

class ResetPasswordUseCase
    extends UseCase<ResetPasswordResponse, ResetPasswordParams> {
  ResetPasswordUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, ResetPasswordResponse>> call(
    ResetPasswordParams params,
  ) {
    return repository.resetPassword(params: params);
  }
}

class ResetPasswordParams extends Params {
  const ResetPasswordParams({
    required this.email,
    required this.code,
    required this.password,
    required this.passwordConfirmation,
    this.cancellation,
  });

  final String email;
  final String code;
  final String password;
  final String passwordConfirmation;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'email': email,
      'code': code,
      'password': password,
      'password_confirmation': passwordConfirmation,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    email,
    code,
    password,
    passwordConfirmation,
    cancellation,
  ];
}
