import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../injection_container.dart';
import '../models/change_company_password_model.dart';
import '../../domain/usecases/change_company_password_usecase.dart';
import '../models/update_company_user_profile_model.dart';
import '../../domain/usecases/update_company_user_profile_usecase.dart';
import '../models/change_student_password_model.dart';
import '../../domain/usecases/change_student_password_usecase.dart';
import '../models/get_company_profile_model.dart';
import '../models/get_student_profile_model.dart';
import '../models/update_company_profile_model.dart';
import '../../domain/usecases/update_company_profile_usecase.dart';
import '../models/update_student_profile_model.dart';
import '../../domain/usecases/update_student_profile_usecase.dart';

abstract class ProfileRemoteDataSource {
  Future<ChangeCompanyPasswordModel> changeCompanyPassword({
    required ChangeCompanyPasswordParams params,
  });

  Future<UpdateCompanyUserProfileModel> updateCompanyUserProfile({
    required UpdateCompanyUserProfileParams params,
  });

  Future<ChangeStudentPasswordModel> changeStudentPassword({
    required ChangeStudentPasswordParams params,
  });

  Future<GetCompanyProfileModel> getCompanyProfile({Object? cancellation});

  Future<GetStudentProfileModel> getStudentProfile({Object? cancellation});

  Future<UpdateCompanyProfileModel> updateCompanyProfile({
    required UpdateCompanyProfileParams params,
  });

  Future<UpdateStudentProfileModel> updateStudentProfile({
    required UpdateStudentProfileParams params,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  @override
  Future<ChangeCompanyPasswordModel> changeCompanyPassword({
    required ChangeCompanyPasswordParams params,
  }) async {
    try {
      String changeCompanyPasswordEndpoint = '/company/profile/password/update';
      final dynamic response = await dioConsumer.patch(
        changeCompanyPasswordEndpoint,
        body: params.toJson(),
        cancelToken: _cancelToken(params.cancellation),
      );

      if (response['status'] == 'success') {
        return ChangeCompanyPasswordModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UpdateCompanyUserProfileModel> updateCompanyUserProfile({
    required UpdateCompanyUserProfileParams params,
  }) async {
    try {
      String updateCompanyUserProfileEndpoint = '/company/profile/update';
      final dynamic response = await dioConsumer.put(
        updateCompanyUserProfileEndpoint,
        body: params.toJson(),
        cancelToken: _cancelToken(params.cancellation),
      );

      if (response['status'] == 'success') {
        return UpdateCompanyUserProfileModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<ChangeStudentPasswordModel> changeStudentPassword({
    required ChangeStudentPasswordParams params,
  }) async {
    try {
      String changeStudentPasswordEndpoint = '/student/profile/password/update';
      final dynamic response = await dioConsumer.patch(
        changeStudentPasswordEndpoint,
        body: params.toJson(),
        cancelToken: _cancelToken(params.cancellation),
      );

      if (response['status'] == 'success') {
        return ChangeStudentPasswordModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<GetCompanyProfileModel> getCompanyProfile({
    Object? cancellation,
  }) async {
    try {
      const String getCompanyProfileEndpoint = '/company/profile/edit';
      final dynamic response = await dioConsumer.get(
        getCompanyProfileEndpoint,
        cancelToken: _cancelToken(cancellation),
      );

      if (response['status'] == 'success') {
        return GetCompanyProfileModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<GetStudentProfileModel> getStudentProfile({
    Object? cancellation,
  }) async {
    try {
      const String getStudentProfileEndpoint = '/student/profile/edit';
      final dynamic response = await dioConsumer.get(
        getStudentProfileEndpoint,
        cancelToken: _cancelToken(cancellation),
      );

      if (response['status'] == 'success') {
        return GetStudentProfileModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UpdateCompanyProfileModel> updateCompanyProfile({
    required UpdateCompanyProfileParams params,
  }) async {
    try {
      String updateCompanyProfileEndpoint = '/company/company-data/update';
      final dynamic response = await dioConsumer.put(
        updateCompanyProfileEndpoint,
        body: params.toJson(),
        cancelToken: _cancelToken(params.cancellation),
      );

      if (response['status'] == 'success') {
        return UpdateCompanyProfileModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<UpdateStudentProfileModel> updateStudentProfile({
    required UpdateStudentProfileParams params,
  }) async {
    try {
      String updateStudentProfileEndpoint = '/student/profile/update';
      final dynamic response = await dioConsumer.put(
        updateStudentProfileEndpoint,
        body: params.toJson(),
        cancelToken: _cancelToken(params.cancellation),
      );

      if (response['status'] == 'success') {
        return UpdateStudentProfileModel.fromJson(response);
      }
      throw ServerException(message: response['message'] ?? '');
    } catch (error) {
      rethrow;
    }
  }
}

CancelToken? _cancelToken(Object? cancellation) {
  if (cancellation is CancelToken) {
    return cancellation;
  }
  return null;
}
