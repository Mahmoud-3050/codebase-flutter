import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verify_phone_otp_response.dart';
import '../enums/otp_purpose.dart';
import '../repositories/auth_repo.dart';

class VerifyPhoneOtpUseCase
    extends UseCase<VerifyPhoneOtpResponse, VerifyPhoneOtpParams> {
  VerifyPhoneOtpUseCase({required this.repository});

  final AuthRepository repository;

  @override
  Future<Either<Failure, VerifyPhoneOtpResponse>> call(
    VerifyPhoneOtpParams params,
  ) {
    return repository.verifyPhoneOtp(params: params);
  }
}

class VerifyPhoneOtpParams extends Params {
  const VerifyPhoneOtpParams({
    required this.dialingCode,
    required this.phone,
    required this.code,
    required this.purpose,
    this.cancellation,
  });

  final String dialingCode;
  final String phone;
  final String code;
  final OtpPurpose purpose;

  @override
  final Object? cancellation;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dialing_code': dialingCode,
      'phone': phone,
      'code': code,
      'purpose': purpose.wireName,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    dialingCode,
    phone,
    code,
    purpose,
    cancellation,
  ];
}
