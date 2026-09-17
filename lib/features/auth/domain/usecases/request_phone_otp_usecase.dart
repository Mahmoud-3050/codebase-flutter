import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/request_otp_response.dart';
import '../enums/otp_purpose.dart';
import '../repositories/auth_repo.dart';

class RequestPhoneOtpUseCase
    extends UseCase<RequestOtpResponse, RequestPhoneOtpParams> {
  RequestPhoneOtpUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, RequestOtpResponse>> call(
    RequestPhoneOtpParams params,
  ) {
    return repository.requestPhoneOtp(params: params);
  }
}

class RequestPhoneOtpParams extends Params {
  const RequestPhoneOtpParams({
    required this.dialingCode,
    required this.phone,
    this.purpose = OtpPurpose.phoneSignIn,
    this.cancellation,
  });

  final String dialingCode;
  final String phone;
  final OtpPurpose purpose;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dialing_code': dialingCode,
      'phone': phone,
      'purpose': purpose.wireName,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    dialingCode,
    phone,
    purpose,
    cancellation,
  ];
}
