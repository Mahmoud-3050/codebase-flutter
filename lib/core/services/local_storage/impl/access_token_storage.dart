import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../interfaces/local_storage_interface.dart';

final class AccessTokenStorage implements LocalStorageInterface {
  AccessTokenStorage({required this.secureStorage});

  final String _key = 'accessToken';

  final FlutterSecureStorage secureStorage;

  @override
  Future<String?> read({String? key}) async {
    try {
      return await secureStorage.read(key: key ?? _key);
    } catch (e, stackTrace) {
      log('Error reading access token: ${e.toString()}', stackTrace: stackTrace);
      return null;
    }
  }

  @override
  Future<bool> save({required String value, String? key}) async {
    try {
      await secureStorage.write(key: key ?? _key, value: value);
      return true;
    } catch (e, stackTrace) {
      log('Error saving access token: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }

  @override
  Future<bool> remove({String? key}) async {
    try {
      await secureStorage.delete(key: key ?? _key);
      return true;
    } catch (e, stackTrace) {
      log('Error removing access token: ${e.toString()}', stackTrace: stackTrace);
      return false;
    }
  }
}
