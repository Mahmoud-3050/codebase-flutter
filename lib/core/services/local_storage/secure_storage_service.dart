import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class SecureStorageService {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<void> clear();
}

class SecureStorageServiceImpl implements SecureStorageService {
  SecureStorageServiceImpl({required this.instance});

  final FlutterSecureStorage instance;

  @override
  Future<String?> read(String key) => instance.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      instance.write(key: key, value: value);

  @override
  Future<void> delete(String key) => instance.delete(key: key);

  @override
  Future<void> clear() => instance.deleteAll();
}
