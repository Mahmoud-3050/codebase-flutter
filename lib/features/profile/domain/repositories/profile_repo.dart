import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/change_company_password_response.dart';
import '../../domain/usecases/change_company_password_usecase.dart';
import '../../domain/entities/update_company_user_profile_response.dart';
import '../../domain/usecases/update_company_user_profile_usecase.dart';
import '../../domain/entities/change_student_password_response.dart';
import '../../domain/usecases/change_student_password_usecase.dart';
import '../../domain/entities/get_company_profile_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/get_student_profile_response.dart';
import '../../domain/entities/update_company_profile_response.dart';
import '../../domain/usecases/update_company_profile_usecase.dart';
import '../../domain/entities/update_student_profile_response.dart';
import '../../domain/usecases/update_student_profile_usecase.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ChangeCompanyPasswordResponse>> changeCompanyPassword({
    required ChangeCompanyPasswordParams params,
  });


  Future<Either<Failure, UpdateCompanyUserProfileResponse>> updateCompanyUserProfile({
    required UpdateCompanyUserProfileParams params,
  });


  Future<Either<Failure, ChangeStudentPasswordResponse>> changeStudentPassword({
    required ChangeStudentPasswordParams params,
  });


  Future<Either<Failure, GetCompanyProfileResponse>> getCompanyProfile({
    required NoParams params,
  });


  Future<Either<Failure, GetStudentProfileResponse>> getStudentProfile({
    required NoParams params,
  });


  Future<Either<Failure, UpdateCompanyProfileResponse>> updateCompanyProfile({
    required UpdateCompanyProfileParams params,
  });


  Future<Either<Failure, UpdateStudentProfileResponse>> updateStudentProfile({
    required UpdateStudentProfileParams params,
  });


}
