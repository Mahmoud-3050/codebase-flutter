import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/request_password_reset_response.dart';
import '../repositories/auth_repo.dart';

class RequestPasswordResetUseCase
    extends UseCase<RequestPasswordResetResponse, RequestPasswordResetParams> {
  RequestPasswordResetUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, RequestPasswordResetResponse>> call(
    RequestPasswordResetParams params,
  ) {
    return repository.requestPasswordReset(params: params);
  }
}

class RequestPasswordResetParams extends Params {
  const RequestPasswordResetParams({required this.email, this.cancellation});

  final String email;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{'email': email};

  @override
  List<Object?> get props => <Object?>[email, cancellation];
}
