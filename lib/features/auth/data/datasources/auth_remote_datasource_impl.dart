import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/api/api_constants.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/dio_consumer.dart';
import '../../../../core/api/request_cancel_token.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../injection_container.dart';
import '../../domain/usecases/complete_registration_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../models/complete_registration_model.dart';
import '../models/login_model.dart';
import '../models/logout_model.dart';
import '../models/register_model.dart';
import '../models/request_otp_model.dart';
import '../models/request_password_reset_model.dart';
import '../models/reset_password_model.dart';
import '../models/social_sign_in_model.dart';
import '../models/verify_email_model.dart';
import '../models/verify_phone_otp_model.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({DioConsumer? client}) : _client = client;

  final DioConsumer? _client;

  DioConsumer get _http => _client ?? dioConsumer;

  Future<Map<String, dynamic>> _post({
    required String path,
    required Params params,
    String? avatarPath,
  }) async {
    final Map<String, dynamic> body = params.toJson();
    final dynamic response;
    if (avatarPath != null && avatarPath.isNotEmpty) {
      final FormData formData = FormData.fromMap(<String, dynamic>{
        ...body,
        'avatar': await MultipartFile.fromFile(
          avatarPath,
          filename: File(avatarPath).uri.pathSegments.last,
        ),
      });
      response = await _http.post(
        path,
        formData: formData,
        cancelToken: requestCancelToken(params.cancellation),
      );
    } else {
      response = await _http.post(
        path,
        body: body,
        cancelToken: requestCancelToken(params.cancellation),
      );
    }
    if (response is Map<String, dynamic> && ApiResponse.isSuccess(response)) {
      return response;
    }
    throw ApiResponse.exceptionOf(response);
  }

  @override
  Future<RegisterModel> register({required Params params}) async {
    final String? avatarPath = params is RegisterParams
        ? params.avatarPath
        : null;
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.registerPath,
      params: params,
      avatarPath: avatarPath,
    );
    return RegisterModel.fromJson(json);
  }

  @override
  Future<LoginModel> login({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.loginPath,
      params: params,
    );
    return LoginModel.fromJson(json);
  }

  @override
  Future<VerifyEmailModel> verifyEmail({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.verifyEmailPath,
      params: params,
    );
    return VerifyEmailModel.fromJson(json);
  }

  @override
  Future<RequestOtpModel> requestEmailOtp({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.emailOtpRequestPath,
      params: params,
    );
    return RequestOtpModel.fromJson(json);
  }

  @override
  Future<RequestOtpModel> requestPhoneOtp({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.phoneOtpRequestPath,
      params: params,
    );
    return RequestOtpModel.fromJson(json);
  }

  @override
  Future<VerifyPhoneOtpModel> verifyPhoneOtp({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.verifyPhoneNumberPath,
      params: params,
    );
    return VerifyPhoneOtpModel.fromJson(json);
  }

  @override
  Future<SocialSignInModel> socialSignIn({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.socialSignInPath,
      params: params,
    );
    return SocialSignInModel.fromJson(json);
  }

  @override
  Future<CompleteRegistrationModel> completeRegistration({
    required Params params,
  }) async {
    final String? avatarPath = params is CompleteRegistrationParams
        ? params.avatarPath
        : null;
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.completeRegistrationPath,
      params: params,
      avatarPath: avatarPath,
    );
    return CompleteRegistrationModel.fromJson(json);
  }

  @override
  Future<RequestPasswordResetModel> requestPasswordReset({
    required Params params,
  }) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.forgotPasswordPath,
      params: params,
    );
    return RequestPasswordResetModel.fromJson(json);
  }

  @override
  Future<ResetPasswordModel> resetPassword({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.resetPasswordPath,
      params: params,
    );
    return ResetPasswordModel.fromJson(json);
  }

  @override
  Future<LogoutModel> logout({required Params params}) async {
    final Map<String, dynamic> json = await _post(
      path: ApiConstants.logoutPath,
      params: params,
    );
    return LogoutModel.fromJson(json);
  }
}
