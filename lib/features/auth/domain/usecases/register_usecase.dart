import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/register_response.dart';
import '../repositories/auth_repo.dart';

class RegisterUseCase extends UseCase<RegisterResponse, RegisterParams> {
  RegisterUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, RegisterResponse>> call(RegisterParams params) {
    return repository.register(params: params);
  }
}

class RegisterParams extends Params {
  const RegisterParams({
    required this.fullName,
    required this.email,
    required this.dialingCode,
    required this.phone,
    required this.password,
    this.avatarPath,
    this.cancellation,
  });

  final String fullName;
  final String email;
  final String dialingCode;
  final String phone;
  final String password;
  final String? avatarPath;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'full_name': fullName,
      'email': email,
      'dialing_code': dialingCode,
      'phone': phone,
      'password': password,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    fullName,
    email,
    dialingCode,
    phone,
    password,
    avatarPath,
    cancellation,
  ];
}
