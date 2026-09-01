import '../../utils/console_logger.dart';
import '../../utils/functions.dart';
import '../models/layer.dart';
import '../models/sub_layer.dart';

void generateFeatureDirectories(
  String feature,
  String featurePath, {
  bool generateTest = false,
}) {
  try {
    createDirectory(featurePath);

    final List<Layer> layers = _buildCleanArchitectureLayers(
      feature,
      featurePath,
    );
    _createLayerDirectories(layers);

    if (generateTest) {
      final String testFeaturePath = featurePath.replaceAll(
        'lib/features',
        'test/features',
      );
      createDirectory(testFeaturePath);

      final List<Layer> testLayers = _buildTestLayers(testFeaturePath);
      _createLayerDirectories(testLayers);
    }
  } catch (e) {
    ConsoleLogger.error('Failed creating layers -> ${e.toString()}');
  }
}

List<Layer> _buildCleanArchitectureLayers(String feature, String featurePath) {
  return [
    Layer(
      title: 'presentation',
      path: '$featurePath/presentation',
      subLayers: const [
        SubLayer(title: 'controller', filesName: []),
        SubLayer(title: 'pages', filesName: []),
        SubLayer(title: 'widgets', filesName: []),
      ],
    ),
    Layer(
      title: 'domain',
      path: '$featurePath/domain',
      subLayers: [
        const SubLayer(title: 'entities', filesName: []),
        SubLayer(title: 'repositories', filesName: ['${feature}_repo.dart']),
        const SubLayer(title: 'usecases', filesName: []),
      ],
    ),
    Layer(
      title: 'data',
      path: '$featurePath/data',
      subLayers: [
        SubLayer(
          title: 'datasources',
          filesName: ['${feature}_remote_datasource.dart'],
        ),
        SubLayer(
          title: 'repositories',
          filesName: ['${feature}_repo_impl.dart'],
        ),
        const SubLayer(title: 'models', filesName: []),
      ],
    ),
  ];
}

List<Layer> _buildTestLayers(String testFeaturePath) {
  return [
    Layer(
      title: 'presentation',
      path: '$testFeaturePath/presentation',
      subLayers: const [SubLayer(title: 'controller', filesName: [])],
    ),
    Layer(
      title: 'domain',
      path: '$testFeaturePath/domain',
      subLayers: const [SubLayer(title: 'usecases', filesName: [])],
    ),
    Layer(
      title: 'data',
      path: '$testFeaturePath/data',
      subLayers: const [
        SubLayer(title: 'datasources', filesName: []),
        SubLayer(title: 'repositories', filesName: []),
      ],
    ),
  ];
}

void _createLayerDirectories(List<Layer> layers) {
  for (final Layer layer in layers) {
    createDirectory(layer.path);
    for (final SubLayer subLayer in layer.subLayers) {
      createDirectory('${layer.path}/${subLayer.title}');
    }
  }
}
