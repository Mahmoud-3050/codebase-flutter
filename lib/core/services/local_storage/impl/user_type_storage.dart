import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

import '../interfaces/local_storage_interface.dart';

final class UserTypeStorage implements LocalStorageInterface {
  UserTypeStorage({required this.preferences});

  final String _key = 'userType';

  final SharedPreferences preferences;

  @override
  Future<String?> read({String? key}) async {
    try {
      return preferences.getString(key ?? _key);
    } catch (e, stackTrace) {
      log('Error reading user type: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> save({required String value, String? key}) async {
    try {
      await preferences.setString(key ?? _key, value);
      return true;
    } catch (e, stackTrace) {
      log('Error saving user type: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> remove({String? key}) async {
    try {
      await preferences.remove(key ?? _key);
      return true;
    } catch (e, stackTrace) {
      log('Error removing user type: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }
}
