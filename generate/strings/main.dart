import 'dart:convert';
import 'dart:io';

import '../utils/constants.dart';
import 'src/strings_generator.dart';

/// Run from the project root:
/// `dart generate/strings/main.dart`
///
/// Applies `lang.json` (key → `{ "en": "...", "ar_EG": "..." }`) to every
/// existing `assets/lang/*.json`. Does not create missing files.
///
/// Delete keys listed in `lang.json` from those files and regenerate Strings:
/// `dart generate/strings/main.dart --d`
void main(List<String> args) async {
  final StringsGenerateMode mode = args.contains('--d')
      ? StringsGenerateMode.delete
      : StringsGenerateMode.append;
  const String filePath = GenerateConstants.langJsonAssetFilePath;
  final File file = File(filePath);
  await handleFileChange(file, mode: mode);
}

Future<void> handleFileChange(
  File file, {
  required StringsGenerateMode mode,
}) async {
  final String currentContent = file.readAsStringSync();
  final Object? decoded = json.decode(currentContent);
  if (decoded is! Map) {
    throw const FormatException('lang.json must be a JSON object');
  }
  final Map<String, dynamic> jsonMap = Map<String, dynamic>.from(decoded);

  final List<File> localeFiles = existingLangJsonFiles();
  if (localeFiles.isEmpty) {
    throw StateError(
      'No language JSON files in ${GenerateConstants.langAssetsDirectory}',
    );
  }

  final Map<String, Map<String, dynamic>> updatedByStem =
      <String, Map<String, dynamic>>{};
  for (final File localeFile in localeFiles) {
    final String stem = langStemFromFileName(localeFile.uri.pathSegments.last)!;
    updatedByStem[stem] = await generateJsonTranslate(
      file: localeFile,
      lang: stem,
      jsonMap: jsonMap,
      mode: mode,
    );
  }

  final String sourceStem = stringsSourceStem(updatedByStem.keys)!;
  await generateAppStrings(updatedByStem[sourceStem]!);
}

List<File> existingLangJsonFiles() {
  final Directory dir = Directory(GenerateConstants.langAssetsDirectory);
  if (!dir.existsSync()) {
    return <File>[];
  }
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in dir.listSync()) {
    if (entity is! File) {
      continue;
    }
    if (langStemFromFileName(entity.uri.pathSegments.last) == null) {
      continue;
    }
    files.add(entity);
  }
  files.sort(
    (File a, File b) =>
        a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last),
  );
  return files;
}

Future<Map<String, dynamic>> generateJsonTranslate({
  required File file,
  required String lang,
  required Map<String, dynamic> jsonMap,
  StringsGenerateMode mode = StringsGenerateMode.append,
}) async {
  try {
    final String updated = applyLangJsonEntries(
      existingJson: file.readAsStringSync(),
      incoming: jsonMap,
      lang: lang,
      mode: mode,
    );
    await file.writeAsString(updated);
    print(
      '${GenerateConstants.greenColorCode} lang.json Updated successfully at ${file.path} ${GenerateConstants.resetColorCode}',
    );
    return Map<String, dynamic>.from(json.decode(updated) as Map);
  } catch (e) {
    print('generateJsonTranslate Error: ${e.toString()}');
    rethrow;
  }
}

Future<void> generateAppStrings(Map<String, dynamic> jsonMap) async {
  final String source = buildStringsClassSource(jsonMap);
  final File file = File(GenerateConstants.outputStringsFilePath);
  await file.writeAsString(source);
  print(
    '${GenerateConstants.greenColorCode} class Strings Generated successfully at ${GenerateConstants.outputStringsFilePath} ${GenerateConstants.resetColorCode}',
  );
}
