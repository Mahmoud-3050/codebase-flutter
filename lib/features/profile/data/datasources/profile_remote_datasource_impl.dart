import '../../../../core/api/api_response.dart';
import '../../../../core/api/request_cancel_token.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../models/change_company_password_model.dart';
import '../models/change_student_password_model.dart';
import '../models/get_company_profile_model.dart';
import '../models/get_student_profile_model.dart';
import '../models/update_company_profile_model.dart';
import '../models/update_company_user_profile_model.dart';
import '../models/update_student_profile_model.dart';
import 'profile_remote_datasource.dart';

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ChangeCompanyPasswordModel> changeCompanyPassword({
    required Params params,
  }) async {
    try {
      const String changeCompanyPasswordEndpoint =
          '/company/profile/password/update';
      final dynamic response = await dioConsumer.patch(
        changeCompanyPasswordEndpoint,
        body: params.toJson(),
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return ChangeCompanyPasswordModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UpdateCompanyUserProfileModel> updateCompanyUserProfile({
    required Params params,
  }) async {
    try {
      const String updateCompanyUserProfileEndpoint = '/company/profile/update';
      final dynamic response = await dioConsumer.put(
        updateCompanyUserProfileEndpoint,
        body: params.toJson(),
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return UpdateCompanyUserProfileModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<ChangeStudentPasswordModel> changeStudentPassword({
    required Params params,
  }) async {
    try {
      const String changeStudentPasswordEndpoint =
          '/student/profile/password/update';
      final dynamic response = await dioConsumer.patch(
        changeStudentPasswordEndpoint,
        body: params.toJson(),
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return ChangeStudentPasswordModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<GetCompanyProfileModel> getCompanyProfile({
    required Params params,
  }) async {
    try {
      const String getCompanyProfileEndpoint = '/company/profile/edit';
      final dynamic response = await dioConsumer.get(
        getCompanyProfileEndpoint,
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return GetCompanyProfileModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<GetStudentProfileModel> getStudentProfile({
    required Params params,
  }) async {
    try {
      const String getStudentProfileEndpoint = '/student/profile/edit';
      final dynamic response = await dioConsumer.get(
        getStudentProfileEndpoint,
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return GetStudentProfileModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UpdateCompanyProfileModel> updateCompanyProfile({
    required Params params,
  }) async {
    try {
      const String updateCompanyProfileEndpoint =
          '/company/company-data/update';
      final dynamic response = await dioConsumer.put(
        updateCompanyProfileEndpoint,
        body: params.toJson(),
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return UpdateCompanyProfileModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UpdateStudentProfileModel> updateStudentProfile({
    required Params params,
  }) async {
    try {
      const String updateStudentProfileEndpoint = '/student/profile/update';
      final dynamic response = await dioConsumer.put(
        updateStudentProfileEndpoint,
        body: params.toJson(),
        cancelToken: requestCancelToken(params.cancellation),
      );

      if (ApiResponse.isSuccess(response)) {
        return UpdateStudentProfileModel.fromJson(response);
      }
      throw ApiResponse.exceptionOf(response);
    } catch (error) {
      rethrow;
    }
  }
}
