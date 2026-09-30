import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/social_sign_in_response.dart';
import '../enums/social_provider.dart';
import '../repositories/auth_repo.dart';

class SocialSignInUseCase
    extends UseCase<SocialSignInResponse, SocialSignInParams> {
  SocialSignInUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, SocialSignInResponse>> call(
    SocialSignInParams params,
  ) {
    return repository.socialSignIn(params: params);
  }
}

class SocialSignInParams extends Params {
  const SocialSignInParams({
    required this.provider,
    this.idToken,
    this.authorizationCode,
    this.fullName,
    this.email,
    this.cancellation,
  });

  final SocialProvider provider;
  final String? idToken;
  final String? authorizationCode;
  final String? fullName;
  final String? email;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'provider': provider.wireName,
      if (idToken != null) 'id_token': idToken,
      if (authorizationCode != null) 'authorization_code': authorizationCode,
      if (fullName != null) 'full_name': fullName,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    provider,
    idToken,
    authorizationCode,
    fullName,
    email,
    cancellation,
  ];
}
