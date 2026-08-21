import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/themes/app_theme.dart';
import 'core/api/app_interceptors.dart';
import 'core/api/dio_consumer.dart';
import 'core/services/local_storage/secure_storage_service.dart';
import 'core/services/local_storage/shared_preferences_service.dart';
import 'core/utils/enums.dart';
import 'core/utils/general_methods.dart';
import 'core/utils/values/colors.dart';
import 'features/profile/profile_injection.dart';
import 'features/theme/theme_injection.dart';

abstract class ServiceLocator {
  static final GetIt instance = GetIt.instance;

  static Future<void> init() async {
    instance.allowReassignment = true;

    /// Features
    await initThemeFeatureInjection();
    await initProfileFeatureInjection();

    /// Core
    injectFCMTokenSingleton('');
    await _injectSharedPreferences();
    _injectSharedPreferencesService();
    _injectSecureStorageService();
    _injectSecureStorage();
    _injectDio();
    _injectDioConsumer();
    _injectAppInterceptors();
    _injectPrettyDioLogInterceptor();
    _injectLogInterceptor();
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
        () => DioConsumerImpl(client: instance()));
  }

  static void _injectAppInterceptors() {
    instance.registerLazySingleton<AppInterceptors>(() => AppInterceptors());
  }

  static void _injectPrettyDioLogInterceptor() {
    instance.registerLazySingleton<PrettyDioLogger>(() => PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          logPrint: (text) => log(text.toString(), name: 'logger'),
        ));
  }

  static void _injectLogInterceptor() {
    instance.registerLazySingleton<LogInterceptor>(() => LogInterceptor(
          requestBody: true,
          responseBody: true,
        ));
  }

  static Future<void> _injectSharedPreferences() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    instance.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  }

  static Future<void> _injectSharedPreferencesService() async {
    instance.registerLazySingleton<SharedPreferencesService>(
        () => SharedPreferencesServiceImpl(instance: instance()));
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

  static void injectAppColors(BuildContext context, {Themes? theme}) async {
    if (theme != null) {
      instance.registerLazySingleton<AppColors>(() =>
          getAppTheme(context: context, isLightTheme: theme == Themes.light)
              .extension<AppColors>()!);
      log('injectAppColors theme != null');
    } else {
      instance.registerLazySingleton<AppColors>(
          () => Theme.of(context).extension<AppColors>()!);
      log('injectAppColors of(context)');
    }
  }

  static void injectAppTheme(Themes theme) async {
    instance.registerLazySingleton<Themes>(() => theme);
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

SecureStorageService get secureStorageService =>
    ServiceLocator.instance<SecureStorageService>();

DioConsumer get dioConsumer => ServiceLocator.instance<DioConsumer>();

AppInterceptors get appInterceptors =>
    ServiceLocator.instance<AppInterceptors>();

LogInterceptor get logInterceptor => ServiceLocator.instance<LogInterceptor>();

PrettyDioLogger get prettyDioLogger =>
    ServiceLocator.instance<PrettyDioLogger>();

AppColors get colors => ServiceLocator.instance<AppColors>();

Themes get appTheme => ServiceLocator.instance<Themes>();

List<String> get routesStack =>
    ServiceLocator.instance<List<String>>(instanceName: 'routesStack');

String get fcmToken =>
    ServiceLocator.instance<String>(instanceName: 'fcmToken');

DeviceType get deviceType =>
    ServiceLocator.instance<DeviceType>(instanceName: 'deviceType');

String? get deviceId =>
    ServiceLocator.instance<String>(instanceName: 'deviceId');
