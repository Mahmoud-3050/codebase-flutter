import 'sub_layer.dart';

class Layer {
  final String title;
  final List<SubLayer> subLayers;
  final String path;

  const Layer({
    required this.title,
    required this.subLayers,
    required this.path,
  });
}