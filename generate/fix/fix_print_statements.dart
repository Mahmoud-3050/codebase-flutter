// ignore_for_file: avoid_print
import 'dart:io';

void main() async {
  final libDirectory = Directory('lib');

  if (!await libDirectory.exists()) {
    print('Error: lib folder not found');
    return;
  }

  print('Scanning lib folder for Dart files...\n');

  await processDirectory(libDirectory);

  print('\n✅ Process completed!');
}

Future<void> processDirectory(Directory directory) async {
  await for (final entity in directory.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      await processFile(entity);
    }
  }
}

Future<void> processFile(File file) async {
  try {
    String content = await file.readAsString();
    String originalContent = content;
    bool hasChanges = false;

    // Check if file contains print or debugPrint statements
    final hasPrint = RegExp(r'\bprint\s*\(').hasMatch(content);
    final hasDebugPrint = RegExp(r'\bdebugPrint\s*\(').hasMatch(content);

    if (!hasPrint && !hasDebugPrint) {
      return; // Skip files without print statements
    }

    print('Processing: ${file.path}');

    // Check if dart:developer import exists
    final hasDartDeveloperImport = content.contains("import 'dart:developer';");

    // Replace print( with log(
    content = content.replaceAllMapped(RegExp(r'\bprint\s*\('), (match) {
      hasChanges = true;
      return 'log(';
    });

    // Replace debugPrint( with log(
    content = content.replaceAllMapped(RegExp(r'\bdebugPrint\s*\('), (match) {
      hasChanges = true;
      return 'log(';
    });

    // Add dart:developer import if needed and changes were made
    if (hasChanges && !hasDartDeveloperImport) {
      // Find the position to insert the import (at the top, before other imports)
      final importPattern = RegExp(r'''^import\s+["\']''', multiLine: true);
      final match = importPattern.firstMatch(content);

      if (match != null) {
        // Insert before the first import
        content =
            "${content.substring(0, match.start)}import 'dart:developer';\n${content.substring(match.start)}";
      } else {
        // No imports found, add at the beginning (after comments if any)
        final libraryPattern = RegExp(r'^library\s+\w+;', multiLine: true);
        final libraryMatch = libraryPattern.firstMatch(content);

        if (libraryMatch != null) {
          // Add after library declaration
          content =
              "${content.substring(0, libraryMatch.end)}\n\nimport 'dart:developer';\n${content.substring(libraryMatch.end)}";
        } else {
          // Add at the very top
          content = "import 'dart:developer';\n\n$content";
        }
      }
    }

    // Write changes back to file
    if (content != originalContent) {
      await file.writeAsString(content);
      print('  ✓ Updated successfully\n');
    }
  } catch (e) {
    print('  ✗ Error processing ${file.path}: $e\n');
  }
}
