import 'dart:io';

import 'package:image_picker/image_picker.dart';

import '../../domain/avatar_picker.dart';

class AvatarPickerImpl implements AvatarPicker {
  AvatarPickerImpl({
    ImagePicker? picker,
    Future<XFile?> Function()? loadImage,
    Future<int> Function(String path)? readLength,
  }) : _loadImage =
           loadImage ??
           (() {
             return (picker ?? ImagePicker()).pickImage(
               source: ImageSource.gallery,
               maxWidth: maxEdgePx.toDouble(),
               maxHeight: maxEdgePx.toDouble(),
             );
           }),
       _readLength = readLength ?? _fileLength;

  static const int maxEdgePx = 1024;
  static const int maxBytes = 2 * 1024 * 1024;

  final Future<XFile?> Function() _loadImage;
  final Future<int> Function(String path) _readLength;

  static Future<int> _fileLength(String path) => File(path).length();

  @override
  Future<String?> pickAvatar() async {
    final XFile? file = await _loadImage();
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
    final int length = await _readLength(file.path);
    if (length > maxBytes) {
      throw const AvatarRejectedException(reason: AvatarRejectReason.tooLarge);
    }
    return file.path;
  }
}
