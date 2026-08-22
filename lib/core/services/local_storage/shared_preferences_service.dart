import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/enums.dart';
import '../../utils/extensions.dart';

abstract class _AppSharedPreferencesKeys {
  static const userType = 'userType';
}

abstract class SharedPreferencesService {
  final SharedPreferences instance;

  const SharedPreferencesService({
    required this.instance,
  });

  //region:: User Type
  UserType getUserType();

  Future<bool> saveUserType(UserType value);

  Future<bool> removeUserType();

  //endregion

  Future<bool> clearAll();
}

class SharedPreferencesServiceImpl extends SharedPreferencesService {
  SharedPreferencesServiceImpl({required super.instance});

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
