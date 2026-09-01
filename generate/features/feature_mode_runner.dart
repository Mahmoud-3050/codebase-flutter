import 'dart:io';

import '../utils/console_logger.dart';
import '../utils/enums.dart';
import 'models/feature.dart';
import 'models/feature_paths.dart';
import 'models/request.dart';
import 'modes/generate_feature_directories.dart';
import 'modes/generate_feature_files.dart';
import 'modes/modify_feature_files.dart';

class FeatureModeRunner {
  final Feature feature;
  final bool generateTest;

  const FeatureModeRunner({required this.feature, required this.generateTest});

  Future<void> run() async {
    final FeaturePaths paths = FeaturePaths.fromFeatureName(feature.names);

    switch (feature.modeType) {
      case ModeType.generate:
        await _runGenerateMode(paths);
      case ModeType.modify:
        await _runModifyMode();
      case ModeType.delete:
        _runDeleteMode();
      case ModeType.protected:
        ConsoleLogger.info('Feature is in PROTECTED mode.');
        ConsoleLogger.error('CLOSED!');
    }
  }

  Future<void> _runGenerateMode(FeaturePaths paths) async {
    generateFeatureDirectories(
      feature.names.snakeCase,
      paths.featureProjectPath,
      generateTest: generateTest,
    );

    await GenerateFeature.generateFeature(
      feature: feature,
      generateTest: generateTest,
    );

    if (generateTest) {
      await runBuildRunner();
    }

    feature.markAsProtected();
    ConsoleLogger.success(
      'Feature "${feature.names.original}" is created successfully!',
    );
  }

  Future<void> _runModifyMode() async {
    final List<Request> pendingRequests = feature.requests
        .where((request) => request.mode == ModeType.generate)
        .toList();

    await ModifyFeature.modifyFeature(
      feature: feature,
      requests: pendingRequests,
    );

    if (generateTest) {
      await runBuildRunner();
    }

    ConsoleLogger.success(
      'Feature "${feature.names.original}" is modified successfully!',
    );
  }

  void _runDeleteMode() {
    // TODO: Implement delete mode feature removal logic
    ConsoleLogger.warning(
      'Delete mode is not yet implemented for feature "${feature.names.original}".',
    );
  }

  static Future<void> runBuildRunner() async {
    ConsoleLogger.info('Running build_runner to generate test mocks...');
    final Process process = await Process.start('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ], mode: ProcessStartMode.inheritStdio);
    final int exitCode = await process.exitCode;
    if (exitCode == 0) {
      ConsoleLogger.success('Test mocks generated successfully!');
    } else {
      ConsoleLogger.error('build_runner failed with exit code $exitCode');
    }
  }
}
