import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/change_company_password_response.dart';
import '../../domain/entities/change_student_password_response.dart';
import '../../domain/entities/get_company_profile_response.dart';
import '../../domain/entities/get_student_profile_response.dart';
import '../../domain/entities/update_company_profile_response.dart';
import '../../domain/entities/update_company_user_profile_response.dart';
import '../../domain/entities/update_student_profile_response.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ChangeCompanyPasswordResponse>> changeCompanyPassword({
    required Params params,
  });

  Future<Either<Failure, UpdateCompanyUserProfileResponse>>
  updateCompanyUserProfile({required Params params});

  Future<Either<Failure, ChangeStudentPasswordResponse>> changeStudentPassword({
    required Params params,
  });

  Future<Either<Failure, GetCompanyProfileResponse>> getCompanyProfile({
    required Params params,
  });

  Future<Either<Failure, GetStudentProfileResponse>> getStudentProfile({
    required Params params,
  });

  Future<Either<Failure, UpdateCompanyProfileResponse>> updateCompanyProfile({
    required Params params,
  });

  Future<Either<Failure, UpdateStudentProfileResponse>> updateStudentProfile({
    required Params params,
  });
}
