import '../../utils/enums.dart';
import '../../utils/extensions.dart';
import 'shared_preferences_service.dart';

abstract interface class UserTypeStorage {
  UserType read();

  Future<bool> save(UserType value);

  Future<bool> remove();
}

class UserTypeStorageImpl implements UserTypeStorage {
  UserTypeStorageImpl({required this.preferences});

  static const String key = 'userType';

  final SharedPreferencesService preferences;

  @override
  UserType read() =>
      UserTypeExtension.fromString(preferences.getString(key) ?? '');

  @override
  Future<bool> save(UserType value) => preferences.setString(key, value.name);

  @override
  Future<bool> remove() => preferences.remove(key);
}
