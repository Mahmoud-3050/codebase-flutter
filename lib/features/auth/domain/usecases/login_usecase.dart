import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/login_response.dart';
import '../repositories/auth_repo.dart';

class LoginUseCase extends UseCase<LoginResponse, LoginParams> {
  LoginUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, LoginResponse>> call(LoginParams params) {
    return repository.login(params: params);
  }
}

class LoginParams extends Params {
  const LoginParams({
    required this.email,
    required this.password,
    this.cancellation,
  });

  final String email;
  final String password;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'password': password};
  }

  @override
  List<Object?> get props => <Object?>[email, password, cancellation];
}
