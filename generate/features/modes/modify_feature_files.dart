import '../../utils/console_logger.dart';
import '../../utils/enums.dart';
import '../models/feature.dart';
import '../models/request.dart';
import 'generate_feature_files.dart';

abstract class ModifyFeature {
  static Future<void> modifyFeature({
    required Feature feature,
    required List<Request> writableRequests,
    bool generateTest = false,
  }) async {
    for (final Request request in writableRequests) {
      final String action = request.mode == ModeType.modify
          ? 'Modifying'
          : 'Generating';
      ConsoleLogger.info(
        '$action request "${request.names.original}" (mode: ${request.mode.code}).',
      );
      GenerateFeature.generateSingleRequestFiles(
        feature: feature,
        request: request,
        generateTest: generateTest,
      );
    }

    await GenerateFeature.generateProjectFiles(
      feature: feature,
      requests: feature.activeRequests,
    );
  }
}
