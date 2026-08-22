import 'dart:convert';
import 'dart:io';

import '../utils/console_logger.dart';
import '../utils/constants.dart';
import 'src/colors_generator.dart';

/// Run from the project root:
/// `dart generate/colors/main.dart`
void main(List<String> args) async {
  final File jsonFile = File(GenerateConstants.colorsJsonAssetFilePath);
  if (!jsonFile.existsSync()) {
    ConsoleLogger.error(
      'Missing ${GenerateConstants.colorsJsonAssetFilePath}',
    );
    exit(1);
  }

  final dynamic decoded = json.decode(jsonFile.readAsStringSync());
  if (decoded is! Map<String, dynamic>) {
    ConsoleLogger.error(
      'colors.json must be a JSON object of "key": "hex" or "key": "light;dark"',
    );
    exit(1);
  }
  if (decoded.isEmpty) {
    ConsoleLogger.warning('colors.json is empty — nothing to generate');
    return;
  }

  final File palettesFile =
      File(GenerateConstants.outputColorsPalettesFilePath);
  final File extrasFile = File(GenerateConstants.outputExtraColorsFilePath);
  if (!palettesFile.existsSync() || !extrasFile.existsSync()) {
    ConsoleLogger.error(
      'Missing palettes or ExtraColors file. Expected:\n'
      '  ${GenerateConstants.outputColorsPalettesFilePath}\n'
      '  ${GenerateConstants.outputExtraColorsFilePath}',
    );
    exit(1);
  }

  final ColorApplyResult result = applyColors(
    palettes: palettesFile.readAsStringSync(),
    extras: extrasFile.readAsStringSync(),
    json: decoded,
  );

  if (result.applied == 0) {
    ConsoleLogger.warning('No valid colors to apply');
    return;
  }

  await palettesFile.writeAsString(result.palettes);
  await extrasFile.writeAsString(result.extras);
  await Process.run('dart', [
    'format',
    GenerateConstants.outputColorsPalettesFilePath,
    GenerateConstants.outputExtraColorsFilePath,
  ]);
  ConsoleLogger.success(
    'Wrote ${GenerateConstants.outputColorsPalettesFilePath}',
  );
  ConsoleLogger.success(
    'Wrote ${GenerateConstants.outputExtraColorsFilePath}',
  );
}
