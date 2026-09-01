import 'dart:io';

/// Script to find unused assets in Flutter project
///
/// Run:
/// dart run generate/fix/unused_assets_finder.dart
///
/// Delete unused assets:
/// dart run generate/fix/unused_assets_finder.dart --delete
///
/// Limit deletion to specific folders:
/// dart run generate/fix/unused_assets_finder.dart --delete --folders=images,svg,lottie
void main(List<String> args) async {
  print('🔍 Starting unused assets analysis...\n');

  final shouldDelete = args.contains('--delete');

  final foldersArg = args.firstWhere(
    (arg) => arg.startsWith('--folders='),
    orElse: () => '',
  );

  final List<String>? specificFolders = foldersArg.isNotEmpty
      ? foldersArg.split('=')[1].split(',').map((e) => e.trim()).toList()
      : null;

  // Path to Assets class
  final assetsFile = File('lib/core/manager/assets.dart');
  if (!assetsFile.existsSync()) {
    print('❌ Assets file not found at: ${assetsFile.path}');
    return;
  }

  final assetsContent = await assetsFile.readAsString();
  final assetConstants = _extractAssetConstants(assetsContent);
  final assetPathsMap = _extractAssetPathMap(assetsContent);

  print('📦 Found ${assetConstants.length} assets in Assets class\n');

  // Get all project Dart + YAML files
  final projectFiles = await _getProjectFiles(Directory('.'));

  print('📄 Scanning ${projectFiles.length} Dart/YAML files...\n');

  final unusedAssets = <String>[];
  final usedAssets = <String>[];

  for (final assetName in assetConstants) {
    final assetPath = assetPathsMap[assetName] ?? '';
    bool isUsed = false;

    for (final file in projectFiles) {
      if (file.path.endsWith('assets.dart')) continue;

      final content = await file.readAsString();

      if (content.contains('Assets.$assetName') ||
          (assetPath.isNotEmpty && content.contains(assetPath))) {
        isUsed = true;
        usedAssets.add(assetName);
        break;
      }
    }

    if (!isUsed) {
      unusedAssets.add(assetName);
    }
  }

  // Results
  print('═' * 60);
  print('📊 ANALYSIS RESULTS');
  print('═' * 60);
  print('✅ Used assets: ${usedAssets.length}');
  print('❌ Unused assets: ${unusedAssets.length}');
  print('═' * 60);

  if (unusedAssets.isEmpty) {
    print('\n🎉 All assets are being used.');
    return;
  }

  print('\n🚨 UNUSED ASSETS:\n');
  for (final asset in unusedAssets) {
    print('   • Assets.$asset');
  }

  // Extract unused asset file paths
  final unusedPaths = unusedAssets
      .map((e) => assetPathsMap[e])
      .whereType<String>()
      .toList();

  // Apply folder filter
  final filteredPaths = specificFolders != null
      ? unusedPaths.where((path) {
          return specificFolders.any((folder) => path.contains('/$folder/'));
        }).toList()
      : unusedPaths;

  print('\n📁 Unused asset file paths:');
  if (specificFolders != null) {
    print('   (Filtered by: ${specificFolders.join(", ")})\n');
  } else {
    print('');
  }

  for (final path in filteredPaths) {
    print('   • $path');
  }

  // Delete
  if (shouldDelete && filteredPaths.isNotEmpty) {
    print('\n⚠️  WARNING: Delete ${filteredPaths.length} files? (yes/no): ');
    final confirmation = stdin.readLineSync()?.toLowerCase();

    if (confirmation == 'yes' || confirmation == 'y') {
      print('\n🗑️  Deleting files...\n');

      int deleted = 0;
      int failed = 0;

      for (final path in filteredPaths) {
        final file = File(path);
        try {
          if (file.existsSync()) {
            await file.delete();
            deleted++;
            print('   ✅ Deleted: $path');
          } else {
            failed++;
            print('   ⚠️  Not found: $path');
          }
        } catch (e) {
          failed++;
          print('   ❌ Failed: $path ($e)');
        }
      }

      print('\n${'═' * 60}');
      print('📊 DELETION SUMMARY');
      print('═' * 60);
      print('✅ Deleted: $deleted');
      print('❌ Failed: $failed');
      print('═' * 60);

      print('\n💡 After deletion:');
      print('   • Regenerate Assets class');
      print('   • Run flutter clean');
    } else {
      print('\n✋ Deletion cancelled.');
    }
  }
}

/// Extract asset constant names
List<String> _extractAssetConstants(String content) {
  final regex = RegExp(r'static const String (\w+) =');
  return regex.allMatches(content).map((m) => m.group(1)!).toList();
}

/// Map constant → asset path
Map<String, String> _extractAssetPathMap(String content) {
  final regex = RegExp(r'''static const String (\w+) = [\'"](.+?)[\'"]''');
  final matches = regex.allMatches(content);

  return {for (final m in matches) m.group(1)!: m.group(2)!};
}

/// Get all Dart + YAML files in project
Future<List<File>> _getProjectFiles(
  Directory dir, {
  List<String> extensions = const ['.dart', '.yaml', '.yml'],
}) async {
  final files = <File>[];

  await for (final entity in dir.list(recursive: true, followLinks: false)) {
    if (entity is File &&
        extensions.any((ext) => entity.path.endsWith(ext)) &&
        !_isIgnored(entity.path)) {
      files.add(entity);
    }
  }

  return files;
}

/// Ignore build/system folders
bool _isIgnored(String path) {
  return path.contains('.dart_tool') ||
      path.contains('build/') ||
      path.contains('ios/') ||
      path.contains('android/') ||
      path.contains('.git/');
}
