import '../models/feature.dart';
import '../models/request.dart';
import 'generate_feature_files.dart';

abstract class ModifyFeature {
  static Future<void> modifyFeature({
    required Feature feature,
    required List<Request> pendingRequests,
    bool generateTest = false,
  }) async {
    for (final Request request in pendingRequests) {
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
