import 'package:flutter/services.dart';

/// Contract interface for loading asset strings.
abstract interface class AssetLoader {
  Future<String> loadString(String path);
}

/// Default implementation that loads assets using Flutter's [rootBundle].
class RootBundleAssetLoader implements AssetLoader {
  const RootBundleAssetLoader();

  @override
  Future<String> loadString(String path) {
    return rootBundle.loadString(path);
  }
}
