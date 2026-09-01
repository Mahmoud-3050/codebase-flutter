import 'secure_storage_service.dart';

abstract interface class DeviceTokenStorage {
  Future<String?> read();

  Future<void> save(String token);

  Future<void> remove();
}

class DeviceTokenStorageImpl implements DeviceTokenStorage {
  DeviceTokenStorageImpl({required this.secureStorage});

  static const String key = 'deviceToken';

  final SecureStorageService secureStorage;

  @override
  Future<String?> read() => secureStorage.read(key);

  @override
  Future<void> save(String token) => secureStorage.write(key, token);

  @override
  Future<void> remove() => secureStorage.delete(key);
}
