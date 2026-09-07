import 'dart:io';

import '../utils/console_logger.dart';
import 'models/feature.dart';
import 'models/feature_paths.dart';
import 'modes/delete_feature_files.dart';
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
      case .generate:
        await _runGenerateMode(paths);
      case .modify:
        await _runModifyMode();
      case .delete:
        await _runDeleteMode();
      case .protected:
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

    if (feature.deleteRequests.isNotEmpty) {
      await DeleteFeature.deleteRequests(
        feature: feature,
        requests: feature.deleteRequests,
      );
    }

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
    if (!feature.hasModifyWork) {
      ConsoleLogger.warning(
        'Feature modify: no request is marked generate (1), '
        'modify (2), or delete (3). Protected requests (0) were left untouched.',
      );
      return;
    }

    if (feature.deleteRequests.isNotEmpty) {
      await DeleteFeature.deleteRequests(
        feature: feature,
        requests: feature.deleteRequests,
      );
    }

    await ModifyFeature.modifyFeature(
      feature: feature,
      writableRequests: feature.writableRequests,
      generateTest: generateTest,
    );

    if (generateTest) {
      await runBuildRunner();
    }

    ConsoleLogger.success(
      'Feature "${feature.names.original}" is modified successfully!',
    );
  }

  Future<void> _runDeleteMode() async {
    await DeleteFeature.deleteRequests(
      feature: feature,
      requests: feature.deleteRequests,
    );

    await GenerateFeature.generateProjectFiles(
      feature: feature,
      requests: feature.activeRequests,
    );

    ConsoleLogger.success(
      'Delete mode finished for feature "${feature.names.original}".',
    );
  }

  static Future<void> runBuildRunner() async {
    ConsoleLogger.info('Running build_runner to generate test mocks...');
    final Process process = await Process.start('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ], mode: .inheritStdio);
    final int exitCode = await process.exitCode;
    if (exitCode == 0) {
      ConsoleLogger.success('Test mocks generated successfully!');
    } else {
      ConsoleLogger.error('build_runner failed with exit code $exitCode');
    }
  }
}
