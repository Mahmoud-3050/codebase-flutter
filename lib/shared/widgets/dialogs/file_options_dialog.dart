import 'package:flutter/material.dart';
import 'package:screen_util/screen_util.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/utils/extensions.dart';
import '../app_outlined_button.dart';

class FileOptionsDialog extends StatelessWidget {
  final String buttonUploadTitle;
  final String buttonShowTitle;
  final String? fileUrl;
  final void Function(PlatformFile file) onFilePickerResult;

  const FileOptionsDialog({
    required this.buttonUploadTitle,
    required this.buttonShowTitle,
    required this.onFilePickerResult,
    this.fileUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 16.w, vertical: 16.h),
      child: Wrap(
        runSpacing: 32.h,
        children: [
          AppOutlinedButton(
            onPressed: () async {
              Navigator.pop(context);
              final file = await FilePicker.pickFile(
                type: .custom,
                allowedExtensions: const ['pdf', 'png', 'jpg', 'jpeg'],
              );
              if (file != null) {
                onFilePickerResult(file);
              }
            },
            text: buttonUploadTitle,
          ),
          if (fileUrl != null && fileUrl!.isNotEmpty)
            AppOutlinedButton(
              onPressed: () async {
                Navigator.pop(context);
                await fileUrl?.launcherUrl;
              },
              text: buttonShowTitle,
            ),
        ],
      ),
    );
  }
}
