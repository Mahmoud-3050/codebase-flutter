import 'dart:io';
import '../../utils/constants.dart';
import '../../utils/names_helper.dart';
import '../../utils/functions.dart';
import 'router_utils.dart';

class ScreenGenerator {
  static Future<bool> generateScreenFile(
    String feature,
    String screenClass,
    String screenSnake,
    Map<String, dynamic> args,
  ) async {
    final String pagesPath = 'lib/features/$feature/presentation/pages';
    final String screenFilePath = '$pagesPath/$screenSnake.dart';
    final File screenFile = File(screenFilePath);

    final String initialContent = buildFullPageContent(screenClass, args);

    if (screenFile.existsSync()) {
      String existing = await screenFile.readAsString();
      if (existing.trim() == initialContent.trim()) return false;

      // If it's a basic placeholder, just overwrite
      if (existing.contains('Placeholder()')) {
        await screenFile.writeAsString(initialContent);
        print(
          '${GenerateConstants.greenColorCode}Updated screen file $screenSnake.dart${GenerateConstants.resetColorCode}',
        );
        return true;
      }

      // If it exists but has custom code, update ONLY args and constructor
      String updated = updateExistingScreenArgs(existing, screenClass, args);
      if (updated != existing) {
        await screenFile.writeAsString(updated);
        print(
          '${GenerateConstants.greenColorCode}Updated existing screen args for $screenClass${GenerateConstants.resetColorCode}',
        );
        return true;
      }
      return false;
    }

    if (!Directory(pagesPath).existsSync()) {
      Directory(pagesPath).createSync(recursive: true);
    }
    await screenFile.writeAsString(initialContent);
    print(
      '${GenerateConstants.greenColorCode}Created screen file $screenSnake.dart${GenerateConstants.resetColorCode}',
    );
    return true;
  }

  static String updateExistingScreenArgs(
    String content,
    String screenClass,
    Map<String, dynamic> args,
  ) {
    int classIndex = content.indexOf('class $screenClass');
    if (classIndex == -1) return content;

    int openBrace = content.indexOf('{', classIndex);
    if (openBrace == -1) return content;

    int classEnd = RouterUtils.findBlockEnd(content, classIndex);
    if (classEnd == -1) return content;

    String classBody = content.substring(openBrace + 1, classEnd - 1);

    // 1. Remove old final fields
    classBody = classBody.replaceAll(
      RegExp(r'^\s*final .*?;', multiLine: true),
      '',
    );

    // 2. Remove old constructors (simplistic match for class name)
    classBody = classBody.replaceAll(
      RegExp('const \\s*$screenClass\\s*\\(.*?\\);', dotAll: true),
      '',
    );
    classBody = classBody.replaceAll(
      RegExp('$screenClass\\s*\\(.*?\\);', dotAll: true),
      '',
    );

    // 3. Insert new fields and constructor at the top
    final StringBuffer buffer = StringBuffer();
    buffer.writeln();
    for (var entry in args.entries) {
      final String argName = NamesHelper.snakeToCamelCase(
        NamesHelper.toSnakeCase(entry.key),
      );
      buffer.writeln('  final ${getDartType(entry.value)} $argName;');
    }
    buffer.writeln();

    if (args.isEmpty) {
      buffer.writeln('  const $screenClass({super.key});');
    } else {
      buffer.writeln('  const $screenClass({');
      buffer.writeln('    super.key,');
      for (var key in args.keys) {
        final String argName = NamesHelper.snakeToCamelCase(
          NamesHelper.toSnakeCase(key),
        );
        buffer.writeln('    required this.$argName,');
      }
      buffer.writeln('  });');
    }

    String result =
        content.substring(0, openBrace + 1) +
        buffer.toString() +
        classBody +
        content.substring(classEnd - 1);

    // Clean up empty lines
    return result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  }

  static String buildFullPageContent(
    String screenClass,
    Map<String, dynamic> args,
  ) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    buffer.writeln();
    buffer.writeln('class $screenClass extends StatefulWidget {');
    for (var entry in args.entries) {
      final String argName = NamesHelper.snakeToCamelCase(
        NamesHelper.toSnakeCase(entry.key),
      );
      buffer.writeln('  final ${getDartType(entry.value)} $argName;');
    }
    buffer.writeln();
    if (args.isEmpty) {
      buffer.writeln('  const $screenClass({super.key});');
    } else {
      buffer.writeln('  const $screenClass({');
      buffer.writeln('    super.key,');
      for (var key in args.keys) {
        final String argName = NamesHelper.snakeToCamelCase(
          NamesHelper.toSnakeCase(key),
        );
        buffer.writeln('    required this.$argName,');
      }
      buffer.writeln('  });');
    }
    buffer.writeln();
    buffer.writeln('  @override');
    buffer.writeln(
      '  State<$screenClass> createState() => _${screenClass}State();',
    );
    buffer.writeln('}');
    buffer.writeln();
    buffer.writeln('class _${screenClass}State extends State<$screenClass> {');
    buffer.writeln('  @override');
    buffer.writeln('  Widget build(BuildContext context) {');
    buffer.writeln('    return const Placeholder();');
    buffer.writeln('  }');
    buffer.writeln('}');
    return buffer.toString();
  }
}
