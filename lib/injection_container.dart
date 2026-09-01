import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/dio_consumer.dart';
import 'core/services/local_storage/access_token_storage.dart';
import 'core/services/local_storage/device_token_storage.dart';
import 'core/services/local_storage/secure_storage_service.dart';
import 'core/services/local_storage/shared_preferences_service.dart';
import 'core/services/local_storage/user_type_storage.dart';
import 'core/utils/enums.dart';
import 'core/utils/general_methods.dart';
import 'features/profile/profile_injection.dart';

export 'config/themes/extra_colors.dart';

abstract class ServiceLocator {
  static final GetIt instance = GetIt.instance;

  static Future<void> init() async {
    instance.allowReassignment = true;

    /// Features
    await initProfileFeatureInjection();

    /// Core
    injectFCMTokenSingleton('');
    await _injectSharedPreferences();
    _injectSharedPreferencesService();
    _injectUserTypeStorage();
    _injectSecureStorage();
    _injectSecureStorageService();
    _injectAccessTokenStorage();
    _injectDeviceTokenStorage();
    _injectDio();
    _injectDioConsumer();
    injectRoutesStackSingleton(<String>[]);
    injectDeviceTypeSingleton(
        Platform.isIOS ? DeviceType.ios : DeviceType.android);
    injectDeviceIdSingleton(await getDeviceId());
  }

  static void _injectDio() {
    instance.registerLazySingleton<Dio>(() => Dio());
  }

  static void _injectDioConsumer() {
    instance.registerLazySingleton<DioConsumer>(
      () => DioConsumerImpl(client: instance()),
    );
  }

  static Future<void> _injectSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    instance.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  static void _injectSharedPreferencesService() {
    instance.registerLazySingleton<SharedPreferencesService>(
        () => SharedPreferencesServiceImpl(instance: instance()));
  }

  static void _injectUserTypeStorage() {
    instance.registerLazySingleton<UserTypeStorage>(
      () => UserTypeStorageImpl(preferences: instance()),
    );
  }

  static void _injectSecureStorage() {
    AndroidOptions androidOptions =
        const AndroidOptions(encryptedSharedPreferences: true);
    // IOSOptions iosOptions = const IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    final FlutterSecureStorage secureStorage = FlutterSecureStorage(
      aOptions: androidOptions,
      // iOptions: iosOptions,
    );
    instance.registerLazySingleton<FlutterSecureStorage>(() => secureStorage);
  }

  static void _injectSecureStorageService() {
    instance.registerLazySingleton<SecureStorageService>(
        () => SecureStorageServiceImpl(instance: instance()));
  }

  static void _injectAccessTokenStorage() {
    instance.registerLazySingleton<AccessTokenStorage>(
      () => AccessTokenStorageImpl(secureStorage: instance()),
    );
  }

  static void _injectDeviceTokenStorage() {
    instance.registerLazySingleton<DeviceTokenStorage>(
      () => DeviceTokenStorageImpl(secureStorage: instance()),
    );
  }

  static void injectRoutesStackSingleton(List<String> routes) {
    instance.registerLazySingleton<List<String>>(() => routes,
        instanceName: 'routesStack');
  }

  static void injectFCMTokenSingleton(String? fcmToken) {
    instance.registerLazySingleton<String>(() => fcmToken ?? '',
        instanceName: 'fcmToken');
  }

  static void injectDeviceTypeSingleton(DeviceType deviceType) {
    instance.registerLazySingleton<DeviceType>(() => deviceType,
        instanceName: 'deviceType');
  }

  static void injectDeviceIdSingleton(String? deviceId) {
    instance.registerLazySingleton<String>(() => deviceId ?? '',
        instanceName: 'deviceId');
  }

  static void injectNavigatorKeySingleton(
      GlobalKey<NavigatorState> navigatorKey) {
    instance.registerLazySingleton<GlobalKey<NavigatorState>>(
        () => navigatorKey,
        instanceName: 'navigatorKey');
  }
}

SharedPreferencesService get sharedPreferencesService =>
    ServiceLocator.instance<SharedPreferencesService>();

UserTypeStorage get userTypeStorage =>
    ServiceLocator.instance<UserTypeStorage>();

SecureStorageService get secureStorageService =>
    ServiceLocator.instance<SecureStorageService>();

AccessTokenStorage get accessTokenStorage =>
    ServiceLocator.instance<AccessTokenStorage>();

DeviceTokenStorage get deviceTokenStorage =>
    ServiceLocator.instance<DeviceTokenStorage>();

DioConsumer get dioConsumer => ServiceLocator.instance<DioConsumer>();

List<String> get routesStack =>
    ServiceLocator.instance<List<String>>(instanceName: 'routesStack');

String get fcmToken =>
    ServiceLocator.instance<String>(instanceName: 'fcmToken');

DeviceType get deviceType =>
    ServiceLocator.instance<DeviceType>(instanceName: 'deviceType');

String? get deviceId =>
    ServiceLocator.instance<String>(instanceName: 'deviceId');
