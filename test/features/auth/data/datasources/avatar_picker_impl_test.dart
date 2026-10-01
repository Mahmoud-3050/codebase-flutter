import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

import 'package:codebase/features/auth/data/datasources/avatar_picker_impl.dart';
import 'package:codebase/features/auth/domain/avatar_picker.dart';

void main() {
  XFile file({
    required String name,
    String? mimeType,
    String path = '/tmp/avatar',
  }) {
    return XFile.fromData(
      Uint8List.fromList(const <int>[1]),
      name: name,
      mimeType: mimeType,
      path: path,
    );
  }

  test('FR-006a a cancelled picker returns null', () async {
    final AvatarPickerImpl picker = AvatarPickerImpl(
      loadImage: () async => null,
    );
    expect(await picker.pickAvatar(), isNull);
  });

  test('FR-006a a PNG within the size limit is accepted', () async {
    final AvatarPickerImpl picker = AvatarPickerImpl(
      loadImage: () async => file(name: 'photo.png', path: '/tmp/photo.png'),
      readLength: (_) async => 100,
    );
    expect(await picker.pickAvatar(), '/tmp/photo.png');
  });

  test(
    'FR-006a a JPEG mime type is accepted without a file extension',
    () async {
      final AvatarPickerImpl picker = AvatarPickerImpl(
        loadImage: () async => file(name: 'camera', mimeType: 'image/jpeg'),
        readLength: (_) async => 100,
      );
      expect(await picker.pickAvatar(), '/tmp/avatar');
    },
  );

  test('FR-006a a non-image file is rejected', () async {
    final AvatarPickerImpl picker = AvatarPickerImpl(
      loadImage: () async => file(name: 'notes.gif', mimeType: 'image/gif'),
      readLength: (_) async => 100,
    );
    expect(
      picker.pickAvatar(),
      throwsA(
        isA<AvatarRejectedException>().having(
          (AvatarRejectedException error) => error.reason,
          'reason',
          AvatarRejectReason.unsupportedType,
        ),
      ),
    );
  });

  test('FR-006a a file over 2 MB is rejected', () async {
    final AvatarPickerImpl picker = AvatarPickerImpl(
      loadImage: () async => file(name: 'big.png', path: '/tmp/big.png'),
      readLength: (_) async => AvatarPickerImpl.maxBytes + 1,
    );
    expect(
      picker.pickAvatar(),
      throwsA(
        isA<AvatarRejectedException>().having(
          (AvatarRejectedException error) => error.reason,
          'reason',
          AvatarRejectReason.tooLarge,
        ),
      ),
    );
  });
}
