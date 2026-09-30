import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verify_email_response.dart';
import '../repositories/auth_repo.dart';

class VerifyEmailUseCase
    extends UseCase<VerifyEmailResponse, VerifyEmailParams> {
  VerifyEmailUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyEmailResponse>> call(VerifyEmailParams params) {
    return repository.verifyEmail(params: params);
  }
}

class VerifyEmailParams extends Params {
  const VerifyEmailParams({
    required this.email,
    required this.code,
    this.cancellation,
  });

  final String email;
  final String code;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'code': code};
  }

  @override
  List<Object?> get props => <Object?>[email, code, cancellation];
}
