import '../../../../core/usecases/usecase.dart';
import '../models/change_company_password_model.dart';
import '../models/change_student_password_model.dart';
import '../models/get_company_profile_model.dart';
import '../models/get_student_profile_model.dart';
import '../models/update_company_profile_model.dart';
import '../models/update_company_user_profile_model.dart';
import '../models/update_student_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ChangeCompanyPasswordModel> changeCompanyPassword({
    required Params params,
  });

  Future<UpdateCompanyUserProfileModel> updateCompanyUserProfile({
    required Params params,
  });

  Future<ChangeStudentPasswordModel> changeStudentPassword({
    required Params params,
  });

  Future<GetCompanyProfileModel> getCompanyProfile({required Params params});

  Future<GetStudentProfileModel> getStudentProfile({required Params params});

  Future<UpdateCompanyProfileModel> updateCompanyProfile({
    required Params params,
  });

  Future<UpdateStudentProfileModel> updateStudentProfile({
    required Params params,
  });
}
