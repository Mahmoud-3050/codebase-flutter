import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SharedPreferencesService {
  String? getString(String key);

  Future<bool> setString(String key, String value);

  Future<bool> remove(String key);

  Future<bool> clear();
}

class SharedPreferencesServiceImpl implements SharedPreferencesService {
  SharedPreferencesServiceImpl({required this.instance});

  final SharedPreferences instance;

  @override
  String? getString(String key) => instance.getString(key);

  @override
  Future<bool> setString(String key, String value) =>
      instance.setString(key, value);

  @override
  Future<bool> remove(String key) => instance.remove(key);

  @override
  Future<bool> clear() => instance.clear();
}
