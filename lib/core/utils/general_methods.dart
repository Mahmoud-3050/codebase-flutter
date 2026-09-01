import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../injection_container.dart';
import '../widgets/dialogs/loading_dialog.dart';
import '../widgets/dialogs/show_dialog.dart';

Future<DateTime?> selectDate({
  required BuildContext context,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) async {
  final DateTime? selectedDate = await showDatePicker(
    context: context,
    initialDate: initialDate ?? DateTime(DateTime.now().year - 17, 12, 31),
    firstDate: firstDate ?? DateTime(DateTime.now().year - 60),
    lastDate: lastDate ?? DateTime(DateTime.now().year - 17, 12, 31),
  );
  return selectedDate;
}

void showAppLoadingDialog({required BuildContext context, String? title}) {
  showAppDialog(
    context: context,
    child: LoadingDialog(title: title),
    isDismissible: false,
  );
}

// Future<Uint8List?> downloadFileFromUrl(String url) async {
//   try {
//     final http.Response response = await http.get(Uri.parse(url));
//     log('downloadFileFromUrl($url) SUCCESS');
//     return response.bodyBytes;
//   } catch (e) {
//     log('downloadFileFromUrl($url) ERROR: $e');
//     return null;
//   }
// }

Future<bool> requestStoragePermissions() async {
  // Request permissions for media access
  if (await Permission.storage.request().isGranted) {
    return true;
  }

  // Handle specific Android 12+ permissions
  if (await Permission.mediaLibrary.request().isGranted) {
    return true;
  }

  if (await Permission.manageExternalStorage.request().isGranted) {
    return true;
  }
  return false;
}

Future<File?> writeTemporaryFile({
  required Uint8List bytes,
  required String fileName,
  required String extension,
}) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/$fileName.$extension';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    log('writeTemporaryFile($fileName.$extension) SUCCESS');
    return file;
  } catch (e) {
    log('writeTemporaryFile($fileName.$extension) ERROR: $e');
    return null;
  }
}

Future<String?> getDeviceId() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  if (deviceType == .android) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    return androidInfo.id; // Use the Android ID as a fallback
  }
  if (deviceType == .ios) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    return iosInfo.identifierForVendor; // Use the iOS identifierForVendor
  }
  return null;
}

String linkifyHtml(String html) {
  // Detect links that are not already inside <a href="">
  final regex = RegExp(
    r'''((?:(?:https?:\/\/)|(?:www\.))?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(?:\.[a-zA-Z]{2,})?(?:\:\d{1,5})?(?:\/[^\s<>"\'\),]*)?)''',
    caseSensitive: false,
  );

  final buffer = StringBuffer();
  int lastIndex = 0;

  for (final match in regex.allMatches(html)) {
    final url = match.group(0)!;

    // Check if match is inside existing <a> tag
    final before = html.lastIndexOf('<a', match.start);
    final after = html.lastIndexOf('</a>', match.start);
    if (before != -1 && after < before) continue;

    // Write everything before the match
    buffer.write(html.substring(lastIndex, match.start));

    // Remove trailing punctuation
    final trimmed = url.replaceAll(RegExp(r'[.,)]+$'), '');

    // Determine the href (add https:// if missing)
    final href = trimmed.startsWith(RegExp(r'https?://'))
        ? trimmed
        : trimmed.startsWith('www.')
        ? 'https://$trimmed'
        : 'https://$trimmed';

    // Write linkified version
    buffer.write('<a href="$href">$trimmed</a>');

    lastIndex = match.end;
  }

  buffer.write(html.substring(lastIndex));
  return buffer.toString();
}
