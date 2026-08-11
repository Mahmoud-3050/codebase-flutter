import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/enums.dart';
import '../../utils/extensions.dart';

abstract class _AppSharedPreferencesKeys {
  static const appTheme = 'appTheme';
  static const userType = 'userType';
  static const String accessToken = 'accessToken';
  static const String lastEmailLogin = 'lastEmailLogin';
  static const String hasAuthLocal = 'hasAuthLocal';
}

abstract class SharedPreferencesService {
  final SharedPreferences instance;

  const SharedPreferencesService({
    required this.instance,
  });

  //region:: AccessToken
  Future<String?> getAccessToken();

  Future<void> saveAccessToken(String token);

  Future<void> removeAccessToken();

  //endregion



  //region:: App Theme
  Themes getAppTheme();

  Future<bool> saveAppTheme(Themes theme);

  Future<bool> removeAppTheme();

  //endregion

  //region:: Last Email Login
  Future<String?> getLastEmailLogin();

  Future<bool> saveLastEmailLogin(String email);

  Future<bool> removeLastEmailLogin();

  //endregion

  //region:: Has Auth Local
  Future<bool> getHasLocalAuth();

  Future<bool> saveHasLocalAuth(bool value);

  Future<bool> removeHasLocalAuth();

  //endregion

  //region:: User Type
  UserType getUserType();

  Future<bool> saveUserType(UserType value);

  Future<bool> removeUserType();

  //endregion

  Future<bool> clearAll();
}

class SharedPreferencesServiceImpl extends SharedPreferencesService {
  SharedPreferencesServiceImpl({required super.instance});

  //region:: AccessToken
  @override
  Future<String?> getAccessToken() async =>
      instance.getString(_AppSharedPreferencesKeys.accessToken) ?? '';

  @override
  Future<void> saveAccessToken(String token) =>
      instance.setString(_AppSharedPreferencesKeys.accessToken, token);

  @override
  Future<void> removeAccessToken() =>
      instance.remove(_AppSharedPreferencesKeys.accessToken);

  //endregion



  //region:: App Theme
  @override
  Themes getAppTheme() {
    String value = instance.getString(_AppSharedPreferencesKeys.appTheme) ?? '';
    return ThemesExtension.fromString(value);
  }

  @override
  Future<bool> saveAppTheme(Themes theme) =>
      instance.setString(_AppSharedPreferencesKeys.appTheme, theme.name);

  @override
  Future<bool> removeAppTheme() =>
      instance.remove(_AppSharedPreferencesKeys.appTheme);

  //endregion

  //region:: User Type
  @override
  UserType getUserType() => UserTypeExtension.fromString(
      instance.getString(_AppSharedPreferencesKeys.userType) ?? '');

  @override
  Future<bool> saveUserType(UserType value) =>
      instance.setString(_AppSharedPreferencesKeys.userType, value.name);

  @override
  Future<bool> removeUserType() =>
      instance.remove(_AppSharedPreferencesKeys.userType);

//endregion

  //region:: Last Email Login
  @override
  Future<String?> getLastEmailLogin() async =>
      instance.getString(_AppSharedPreferencesKeys.lastEmailLogin);

  @override
  Future<bool> saveLastEmailLogin(String email) =>
      instance.setString(_AppSharedPreferencesKeys.lastEmailLogin, email);

  @override
  Future<bool> removeLastEmailLogin() =>
      instance.remove(_AppSharedPreferencesKeys.lastEmailLogin);

  //endregion

  //region:: Has Local Auth
  @override
  Future<bool> getHasLocalAuth() async =>
      instance.getBool(_AppSharedPreferencesKeys.hasAuthLocal) ?? false;

  @override
  Future<bool> saveHasLocalAuth(bool value) =>
      instance.setBool(_AppSharedPreferencesKeys.hasAuthLocal, value);

  @override
  Future<bool> removeHasLocalAuth() =>
      instance.remove(_AppSharedPreferencesKeys.hasAuthLocal);

  //endregion

  @override
  Future<bool> clearAll() => instance.clear();
}
