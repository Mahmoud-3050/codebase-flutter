import 'dart:io';

import '../../utils/constants.dart';

/// Filesystem lookup for a reusable domain entity under [GenerateConstants.sharedEntitiesPath].
abstract class SharedEntityLookup {
  static File? find(String className) {
    if (className.trim().isEmpty) {
      return null;
    }
    final Directory directory = Directory(GenerateConstants.sharedEntitiesPath);
    if (!directory.existsSync()) {
      return null;
    }

    final RegExp classPattern = RegExp('class\\s+$className\\b');
    final List<File> dartFiles = directory
        .listSync(recursive: true)
        .whereType<File>()
        .where((File file) => file.path.endsWith('.dart'))
        .toList();

    for (final File file in dartFiles) {
      if (classPattern.hasMatch(file.readAsStringSync())) {
        return file;
      }
    }
    return null;
  }

  static String packageImport(File file) {
    String normalized = file.path.replaceAll('\\', '/');
    final int libIndex = normalized.indexOf('lib/');
    if (libIndex >= 0) {
      normalized = normalized.substring(libIndex + 4);
    }
    return 'package:${GenerateConstants.dartPackageName}/$normalized';
  }
}
