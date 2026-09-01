import 'dart:io';

class GlobalChecker {
  static Future<Map<String, String>?> findScreenDefinitionGlobally(
    String screenClass,
  ) async {
    final Directory dir = Directory('lib/features');
    if (!dir.existsSync()) return null;
    final String pattern = '=> ${screenClass.toLowerCase()}(';
    final String constPattern = '=> const ${screenClass.toLowerCase()}(';

    await for (var entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('router.dart')) {
        final String content = (await entity.readAsString()).toLowerCase();
        if (content.contains(pattern) || content.contains(constPattern)) {
          final parts = entity.path.split('/');
          final feature = parts[parts.indexOf('features') + 1];
          return {'feature': feature, 'path': entity.path};
        }
      }
    }
    return null;
  }
}
