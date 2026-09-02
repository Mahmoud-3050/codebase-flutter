import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/api/dio_consumer.dart';
import 'core/services/local_storage/impl/access_token_storage.dart';
import 'core/services/local_storage/impl/device_token_storage.dart';
import 'core/services/local_storage/impl/user_type_storage.dart';
import 'core/utils/enums.dart';
import 'core/utils/general_methods.dart';
import 'features/profile/profile_injection.dart';

abstract class ServiceLocator {
  static final GetIt instance = .instance;

  static Future<void> init() async {
    instance.allowReassignment = true;

    /// Features
    await initProfileFeatureInjection();

    /// Core
    injectFCMTokenSingleton('');
    await _injectSharedPreferences();
    _injectUserTypeStorage();
    _injectSecureStorage();
    _injectAccessTokenStorage();
    _injectDeviceTokenStorage();
    _injectDio();
    _injectDioConsumer();
    injectDeviceTypeSingleton(Platform.isIOS ? .ios : .android);
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
    instance.registerLazySingleton<SharedPreferences>(() => sharedPreferences, instanceName: 'sharedPreferences');
  }

  static void _injectSecureStorage() {
    // IOSOptions iosOptions = const IOSOptions(accessibility: KeychainAccessibility.first_unlock);
    const secureStorage = FlutterSecureStorage(
      // iOptions: iosOptions,
    );
    instance.registerLazySingleton<FlutterSecureStorage>(() => secureStorage, instanceName: 'secureStorage');
  }


  static void _injectUserTypeStorage() {
    instance.registerLazySingleton<UserTypeStorage>(
      () => UserTypeStorage(preferences: instance()),
    );
  }

  static void _injectAccessTokenStorage() {
    instance.registerLazySingleton<AccessTokenStorage>(
      () => AccessTokenStorage(secureStorage: instance()),
    );
  }

  static void _injectDeviceTokenStorage() {
    instance.registerLazySingleton<DeviceTokenStorage>(
      () => DeviceTokenStorage(secureStorage: instance()),
    );
  }

  static void injectFCMTokenSingleton(String? fcmToken) {
    instance.registerLazySingleton<String>(
      () => fcmToken ?? '',
      instanceName: 'fcmToken',
    );
  }

  static void injectDeviceTypeSingleton(DeviceType deviceType) {
    instance.registerLazySingleton<DeviceType>(
      () => deviceType,
      instanceName: 'deviceType',
    );
  }

  static void injectDeviceIdSingleton(String? deviceId) {
    instance.registerLazySingleton<String>(
      () => deviceId ?? '',
      instanceName: 'deviceId',
    );
  }

  static void injectNavigatorKeySingleton(
    GlobalKey<NavigatorState> navigatorKey,
  ) {
    instance.registerLazySingleton<GlobalKey<NavigatorState>>(
      () => navigatorKey,
      instanceName: 'navigatorKey',
    );
  }
}

SharedPreferences get sharedPreferences =>
    ServiceLocator.instance<SharedPreferences>(instanceName: 'sharedPreferences');

FlutterSecureStorage get secureStorage =>
    ServiceLocator.instance<FlutterSecureStorage>(instanceName: 'secureStorage');

UserTypeStorage get userTypeStorage =>
    ServiceLocator.instance<UserTypeStorage>();

AccessTokenStorage get accessTokenStorage =>
    ServiceLocator.instance<AccessTokenStorage>();

DeviceTokenStorage get deviceTokenStorage =>
    ServiceLocator.instance<DeviceTokenStorage>();

DioConsumer get dioConsumer => ServiceLocator.instance<DioConsumer>();


String get fcmToken =>
    ServiceLocator.instance<String>(instanceName: 'fcmToken');

DeviceType get deviceType =>
    ServiceLocator.instance<DeviceType>(instanceName: 'deviceType');

String? get deviceId =>
    ServiceLocator.instance<String>(instanceName: 'deviceId');
