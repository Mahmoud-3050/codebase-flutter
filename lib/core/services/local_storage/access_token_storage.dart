import 'secure_storage_service.dart';

abstract interface class AccessTokenStorage {
  Future<String?> read();

  Future<void> save(String token);

  Future<void> remove();
}

class AccessTokenStorageImpl implements AccessTokenStorage {
  AccessTokenStorageImpl({required this.secureStorage});

  static const String key = 'accessToken';

  final SecureStorageService secureStorage;

  @override
  Future<String?> read() => secureStorage.read(key);

  @override
  Future<void> save(String token) => secureStorage.write(key, token);

  @override
  Future<void> remove() => secureStorage.delete(key);
}
