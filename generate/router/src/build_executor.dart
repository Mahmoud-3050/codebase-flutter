// ignore_for_file: avoid_print
import 'dart:io';
import '../../utils/constants.dart';

class BuildExecutor {
  static Future<void> runBuildRunner() async {
    print(
      '${GenerateConstants.blueColorCode}Running build_runner...${GenerateConstants.resetColorCode}',
    );
    final Process result = await Process.start('dart', [
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ]);

    stdout.addStream(result.stdout);
    stderr.addStream(result.stderr);

    final int exitCode = await result.exitCode;
    if (exitCode == 0) {
      print(
        '${GenerateConstants.greenColorCode}Route processed successfully!${GenerateConstants.resetColorCode}',
      );
    } else {
      print(
        '${GenerateConstants.redColorCode}Build runner failed with exit code $exitCode${GenerateConstants.resetColorCode}',
      );
    }
  }
}
