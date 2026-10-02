import 'dart:io';

import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';

import '../../../../config/language/strings.dart';
import '../../../../shared/widgets/app_elevated_button.dart';

/// Avatar action shared by register and complete registration.
///
/// Shows a preview of the chosen photo above the action, and the action reads
/// "Change photo" once a photo exists.
class AuthAvatarPicker extends StatelessWidget {
  const AuthAvatarPicker({
    required this.avatarPath,
    required this.onPick,
    super.key,
  });

  final String? avatarPath;
  final Future<void> Function() onPick;

  @override
  Widget build(BuildContext context) {
    final String? path = avatarPath;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (path != null) ...<Widget>[
          Center(child: _AvatarPreview(path: path)),
          SizedBox(height: 12.h),
        ],
        AppElevatedButton(
          text: path == null ? Strings.addPhoto : Strings.changePhoto,
          onPressed: onPick,
        ),
      ],
    );
  }
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final double radius = 48.r;
    final double pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final int decodeWidth = (radius * 2 * pixelRatio).ceil();
    return Semantics(
      image: true,
      label: Strings.selectedPhoto,
      child: ExcludeSemantics(
        child: CircleAvatar(
          key: const Key('auth-avatar-preview'),
          radius: radius,
          backgroundImage: ResizeImage(
            FileImage(File(path)),
            width: decodeWidth,
          ),
          // A file removed after picking falls back to the plain circle.
          onBackgroundImageError: (Object error, StackTrace? stackTrace) {},
        ),
      ),
    );
  }
}
