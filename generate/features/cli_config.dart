import '../utils/console_logger.dart';

class CliConfig {
  final String featureName;
  final bool generateTest;

  const CliConfig({required this.featureName, required this.generateTest});

  static CliConfig? parse(List<String> args) {
    try {
      if (args.isEmpty) {
        throw const FormatException(
          'Invalid arguments -> Feature name is empty!',
        );
      }

      final String name = args.firstWhere(
        (arg) => !arg.startsWith('-'),
        orElse: () => '',
      );

      if (name.trim().isEmpty) {
        throw const FormatException(
          'Invalid arguments -> Feature name is empty!',
        );
      }

      final bool generateTest =
          args.contains('--test') ||
          args.contains('-t') ||
          args.contains('--tests');

      return CliConfig(featureName: name.trim(), generateTest: generateTest);
    } on FormatException catch (e) {
      ConsoleLogger.error('EXCEPTION: ${e.message}');
      return null;
    }
  }
}
