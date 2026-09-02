abstract interface class LocalStorageInterface {
  Future<String?> read({String? key});

  Future<bool> save({required String value, String? key});

  Future<bool> remove({String? key});
}
