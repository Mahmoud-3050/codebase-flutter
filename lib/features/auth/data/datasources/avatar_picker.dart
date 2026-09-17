abstract interface class AvatarPicker {
  /// Returns a local file path, or null if the user skipped.
  /// Throws [AvatarRejectedException] when the file is invalid.
  Future<String?> pickAvatar();
}

class AvatarRejectedException implements Exception {
  const AvatarRejectedException({required this.reason});

  final AvatarRejectReason reason;
}

enum AvatarRejectReason { tooLarge, unsupportedType }
