import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class _SecureStorageServiceKeys {
  static const String accessToken = 'accessToken';
  static const String deviceToken = 'deviceToken';
}

abstract class SecureStorageService {
  final FlutterSecureStorage instance;

  const SecureStorageService({
    required this.instance,
  });

  //region:: AccessToken
  Future<String?> getAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> removeAccessToken();

  //endregion

  //region:: DeviceToken
  Future<String?> getDeviceToken();

  Future<void> saveDeviceToken(String token);

  Future<void> removeDeviceToken();

  //endregion

  Future<void> clearAll();
}

class SecureStorageServiceImpl extends SecureStorageService {
  SecureStorageServiceImpl({required super.instance});

  //region:: AccessToken
  @override
  Future<String?> getAccessToken() async =>
      (await instance.readAll())[_SecureStorageServiceKeys.accessToken];

  @override
  Future<void> saveAccessToken(String token) =>
      instance.write(key: _SecureStorageServiceKeys.accessToken, value: token);

  @override
  Future<void> removeAccessToken() =>
      instance.delete(key: _SecureStorageServiceKeys.accessToken);

  //endregion

  //region:: DeviceToken
  @override
  Future<String?> getDeviceToken() async =>
      (await instance.readAll())[_SecureStorageServiceKeys.deviceToken];

  @override
  Future<void> saveDeviceToken(String token) =>
      instance.write(key: _SecureStorageServiceKeys.deviceToken, value: token);

  @override
  Future<void> removeDeviceToken() =>
      instance.delete(key: _SecureStorageServiceKeys.deviceToken);

  //endregion

  @override
  Future<void> clearAll() => instance.deleteAll();
}
