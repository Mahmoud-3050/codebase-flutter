import 'dart:io';

import '../utils/console_logger.dart';
import '../utils/enums.dart';
import 'cli_config.dart';
import 'feature_loader.dart';
import 'feature_mode_runner.dart';
import 'models/feature.dart';

/// To run this generator:
/// `dart generate/features/main.dart <feature_name>`
/// Or to include unit tests:
/// `dart generate/features/main.dart <feature_name> --test`
void main(List<String> args) async {
  final CliConfig? config = CliConfig.parse(args);
  if (config == null) return;

  final Feature? feature = FeatureLoader.load(config.featureName);
  if (feature == null) return;

  if (feature.modeType == ModeType.protected) {
    ConsoleLogger.info('You are in PROTECTED mode');
    ConsoleLogger.error('CLOSED!');
    return;
  }

  if (!_confirmContinuation(feature.modeType)) return;

  final FeatureModeRunner runner = FeatureModeRunner(
    feature: feature,
    generateTest: config.generateTest,
  );

  await runner.run();
}

bool _confirmContinuation(ModeType modeType) {
  ConsoleLogger.info(
    'You are in ${modeType.name.toUpperCase()} mode. Are you sure you want to continue? [y/n]',
  );
  final String? input = stdin.readLineSync();
  if (input?.trim().toLowerCase() != 'y' &&
      input?.trim().toLowerCase() != 'yes') {
    ConsoleLogger.error('CLOSED!');
    return false;
  }
  return true;
}
