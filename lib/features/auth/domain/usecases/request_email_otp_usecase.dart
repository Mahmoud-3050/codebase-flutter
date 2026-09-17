import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/request_otp_response.dart';
import '../enums/otp_purpose.dart';
import '../repositories/auth_repo.dart';

class RequestEmailOtpUseCase
    extends UseCase<RequestOtpResponse, RequestEmailOtpParams> {
  RequestEmailOtpUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, RequestOtpResponse>> call(
    RequestEmailOtpParams params,
  ) {
    return repository.requestEmailOtp(params: params);
  }
}

class RequestEmailOtpParams extends Params {
  const RequestEmailOtpParams({
    required this.email,
    this.purpose = OtpPurpose.verifyEmail,
    this.cancellation,
  });

  final String email;
  final OtpPurpose purpose;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{'email': email, 'purpose': purpose.wireName};
  }

  @override
  List<Object?> get props => <Object?>[email, purpose, cancellation];
}
