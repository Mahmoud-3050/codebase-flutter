import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/complete_registration_response.dart';
import '../enums/registration_source.dart';
import '../repositories/auth_repo.dart';

class CompleteRegistrationUseCase
    extends UseCase<CompleteRegistrationResponse, CompleteRegistrationParams> {
  CompleteRegistrationUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, CompleteRegistrationResponse>> call(
    CompleteRegistrationParams params,
  ) {
    return repository.completeRegistration(params: params);
  }
}

class CompleteRegistrationParams extends Params {
  const CompleteRegistrationParams({
    required this.registrationToken,
    required this.source,
    required this.fullName,
    required this.password,
    this.email,
    this.dialingCode,
    this.phone,
    this.avatarPath,
    this.cancellation,
  });

  final String registrationToken;
  final RegistrationSource source;
  final String fullName;
  final String password;
  final String? email;
  final String? dialingCode;
  final String? phone;
  final String? avatarPath;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'registration_token': registrationToken,
      'full_name': fullName,
      'password': password,
      if (email != null) 'email': email,
      if (dialingCode != null) 'dialing_code': dialingCode,
      if (phone != null) 'phone': phone,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    registrationToken,
    source,
    fullName,
    password,
    email,
    dialingCode,
    phone,
    avatarPath,
    cancellation,
  ];
}
