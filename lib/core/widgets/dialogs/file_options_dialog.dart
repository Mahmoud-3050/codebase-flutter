import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';

import '../../utils/extensions.dart';
import '../app_outlined_button.dart';

class FileOptionsDialog extends StatelessWidget {
  final String buttonUploadTitle;
  final String buttonShowTitle;
  final String? fileUrl;
  final void Function(FilePickerResult filePickerResult) onFilePickerResult;

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
              FilePickerResult? filePickerResult = await FilePicker.pickFiles(
                type: .custom,
                allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
              );
              if (filePickerResult != null) {
                onFilePickerResult.call(filePickerResult);
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
