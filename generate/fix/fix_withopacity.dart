import 'dart:io';

import '../utils/constants.dart';

void main() async {
  print(
    '${GenerateConstants.orangeColorCode} Fix withOpacity Starting... ${GenerateConstants.resetColorCode}',
  );
  final directory = Directory('lib');
  if (!directory.existsSync()) {
    print(
      '${GenerateConstants.redColorCode} ERROR: Directory "${directory.path}" does not exist! ${GenerateConstants.resetColorCode}',
    );
    print(
      '${GenerateConstants.redColorCode} Fix withOpacity Closed. ${GenerateConstants.resetColorCode}',
    );
    return;
  }
  final List<File> searchFiles = searchInDirectory(directory);
  await run(searchFiles);
  print(
    '${GenerateConstants.blueColorCode} Fix withOpacity Finished. ${GenerateConstants.resetColorCode}',
  );
}

List<File> searchInDirectory(Directory directory) {
  final List<FileSystemEntity> files = directory
      .listSync(recursive: true)
      .where((entity) {
        return entity is File && entity.path.endsWith('.dart');
      })
      .toList();
  return files.map((FileSystemEntity item) => File(item.path)).toList();
}

Future<void> run(List<File> searchFiles) async {
  final RegExp regex = RegExp(r'withOpacity\s*\(\s*([0-9.]+)\s*,?\s*\)');

  for (File file in searchFiles) {
    final String original = file.readAsStringSync();
    final String updated = original.replaceAllMapped(regex, (match) {
      final alphaValue = match.group(1);
      return 'withValues(alpha: $alphaValue)';
    });

    if (original != updated) {
      file.writeAsStringSync(updated);
      print(
        '${GenerateConstants.greenColorCode}✔ Updated: ${file.path}${GenerateConstants.resetColorCode}',
      );
    }
  }
}
