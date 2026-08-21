import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/enums.dart';
import '../../utils/extensions.dart';

abstract class _AppSharedPreferencesKeys {
  static const appTheme = 'appTheme';
  static const userType = 'userType';
}

abstract class SharedPreferencesService {
  final SharedPreferences instance;

  const SharedPreferencesService({
    required this.instance,
  });

  //region:: App Theme
  Themes getAppTheme();

  Future<bool> saveAppTheme(Themes theme);

  Future<bool> removeAppTheme();

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

  @override
  Future<bool> clearAll() => instance.clear();
}
