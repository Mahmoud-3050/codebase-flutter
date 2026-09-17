import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'avatar_picker.dart';

class AvatarPickerImpl implements AvatarPicker {
  AvatarPickerImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  static const int maxEdgePx = 1024;
  static const int maxBytes = 2 * 1024 * 1024;

  final ImagePicker _picker;

  @override
  Future<String?> pickAvatar() async {
    final XFile? file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: maxEdgePx.toDouble(),
      maxHeight: maxEdgePx.toDouble(),
    );
    if (file == null) {
      return null;
    }
    final String name = file.name.toLowerCase();
    final String mime = file.mimeType?.toLowerCase() ?? '';
    final bool isJpeg =
        name.endsWith('.jpg') || name.endsWith('.jpeg') || mime == 'image/jpeg';
    final bool isPng = name.endsWith('.png') || mime == 'image/png';
    if (!isJpeg && !isPng) {
      throw const AvatarRejectedException(
        reason: AvatarRejectReason.unsupportedType,
      );
    }
    final int length = await File(file.path).length();
    if (length > maxBytes) {
      throw const AvatarRejectedException(reason: AvatarRejectReason.tooLarge);
    }
    return file.path;
  }
}
