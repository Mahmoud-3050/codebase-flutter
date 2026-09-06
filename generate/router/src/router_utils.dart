import '../../features/models/names.dart';
import '../../utils/names_helper.dart';
import '../../utils/functions.dart';

class RouterUtils {
  static int findBlockEnd(String content, int startIndex) {
    int firstBrace = content.indexOf('{', startIndex);
    if (firstBrace == -1) return -1;

    int braceCount = 1;
    int i = firstBrace + 1;
    while (i < content.length && braceCount > 0) {
      if (content[i] == '{') braceCount++;
      if (content[i] == '}') braceCount--;
      i++;
    }
    return i;
  }

  static String removeBlock(String content, String startPattern) {
    final int patternIndex = content.indexOf(startPattern);
    if (patternIndex == -1) return content;

    final int startIndex = _includePrecedingRouteMeta(content, patternIndex);
    final int blockEnd = findBlockEnd(content, patternIndex);
    if (blockEnd == -1) return content;

    int end = blockEnd;
    while (end < content.length &&
        (content[end] == '\n' || content[end] == '\r')) {
      end++;
    }

    return content.substring(0, startIndex) + content.substring(end);
  }

  static int _includePrecedingRouteMeta(String content, int patternIndex) {
    int startIndex = patternIndex;
    int searchFrom = patternIndex;
    while (searchFrom > 0) {
      final int prevNewline = content.lastIndexOf('\n', searchFrom - 1);
      final int lineStart = prevNewline + 1;
      final String line = content.substring(lineStart, searchFrom).trim();
      if (line.isEmpty || _isRouteMetaLine(line)) {
        startIndex = lineStart;
        if (prevNewline == -1) {
          startIndex = 0;
          break;
        }
        searchFrom = prevNewline;
        continue;
      }
      break;
    }
    return startIndex;
  }

  static bool _isRouteMetaLine(String line) {
    if (line.startsWith('@TypedGoRoute')) return true;
    if (line.startsWith('path:')) return true;
    if (line.startsWith('name:')) return true;
    if (line == ')' || line == '),') return true;
    return RegExp(r"^const String _\w+ScopeName = '[^']+';$").hasMatch(line);
  }

  static String removeScopeConstant(String content, String screenBase) {
    final String camel = Names.fromString(screenBase).camelCase;
    return content.replaceAll(
      RegExp("const String _${camel}ScopeName = '[^']+';\\s*"),
      '',
    );
  }

  static bool argsMatch(
    String content,
    String routeClass,
    Map<String, dynamic> args,
  ) {
    int classStart = content.indexOf('class $routeClass');
    if (classStart == -1) return false;

    int classEnd = findBlockEnd(content, classStart);
    if (classEnd == -1) classEnd = content.length;
    String classContent = content.substring(classStart, classEnd);

    bool hasFields = classContent.contains('final ');

    if (args.isEmpty) {
      return !hasFields;
    }

    for (var key in args.keys) {
      final String argName = NamesHelper.snakeToCamelCase(
        NamesHelper.toSnakeCase(key),
      );
      if (!classContent.contains('final ${getDartType(args[key])} $argName;')) {
        return false;
      }
    }

    int fieldCount = 'final '.allMatches(classContent).length;
    return fieldCount == args.length;
  }

  static bool scopesMatch(
    String content,
    String routeClass,
    List<String> expectedRegisters,
  ) {
    int classStart = content.indexOf('class $routeClass');
    if (classStart == -1) return false;

    int classEnd = findBlockEnd(content, classStart);
    if (classEnd == -1) classEnd = content.length;
    final String classContent = content.substring(classStart, classEnd);

    if (expectedRegisters.isEmpty) {
      return !classContent.contains('FeatureScope');
    }

    if (!classContent.contains('FeatureScope')) return false;

    final Set<String> found = RegExp(
      r'register[A-Z][A-Za-z0-9]*',
    ).allMatches(classContent).map((Match m) => m.group(0)!).toSet();
    final Set<String> expected = expectedRegisters.toSet();
    return found.length == expected.length && found.containsAll(expected);
  }

  static String ensureImport(String content, String importLine) {
    if (content.contains(importLine)) return content;

    final bool isPackage = importLine.contains('package:');
    if (isPackage) {
      final int lastPkg = content.lastIndexOf("import 'package:");
      if (lastPkg != -1) {
        final int endOfLine = content.indexOf('\n', lastPkg);
        if (endOfLine != -1) {
          return '${content.substring(0, endOfLine + 1)}$importLine\n${content.substring(endOfLine + 1)}';
        }
      }
    }

    final int lastImport = content.lastIndexOf('import ');
    if (lastImport != -1) {
      final int endOfLine = content.indexOf('\n', lastImport);
      if (endOfLine != -1) {
        return '${content.substring(0, endOfLine + 1)}$importLine\n${content.substring(endOfLine + 1)}';
      }
    }
    return '$importLine\n$content';
  }

  static String pruneRouterImports(String content, String feature) {
    content = _dropImportIfUnused(
      content,
      'package:flutter_bloc/flutter_bloc.dart',
      const ['BlocProvider', 'MultiBlocProvider'],
    );
    content = _dropImportIfUnused(content, 'core/di/feature_scope.dart', const [
      'FeatureScope',
    ]);
    content = _dropImportIfUnused(content, 'injection_container.dart', const [
      'ServiceLocator',
    ]);
    content = _dropImportIfUnused(content, '${feature}_injection.dart', const [
      'register',
    ]);

    final RegExp cubitImportRe = RegExp(
      r"import '../controller/([^']+)/([^']+)_cubit\.dart';\n?",
    );
    final List<RegExpMatch> matches = cubitImportRe
        .allMatches(content)
        .toList();
    for (int i = matches.length - 1; i >= 0; i--) {
      final RegExpMatch match = matches[i];
      final String cubitSnake = match.group(2)!;
      final String cubitClass =
          '${NamesHelper.snakeToClassCase(cubitSnake)}Cubit';
      final String withoutThisImport = content.replaceRange(
        match.start,
        match.end,
        '',
      );
      if (!withoutThisImport.contains(cubitClass)) {
        content = withoutThisImport;
      }
    }
    return content;
  }

  static String _dropImportIfUnused(
    String content,
    String importFragment,
    List<String> tokens,
  ) {
    final RegExp importRe = RegExp("import '[^']*$importFragment[^']*';\\n?");
    final Match? match = importRe.firstMatch(content);
    if (match == null) return content;

    final String without = content.replaceFirst(importRe, '');
    for (final String token in tokens) {
      if (without.contains(token)) return content;
    }
    return without;
  }

  static String stripNavigationMethods(String content, String screenBase) {
    content = content.replaceAll(
      RegExp(
        '\\s*(void (to|go|push)|Future<T\\?> push)$screenBase(?:<T>)?\\s*\\([\\s\\S]*?\\)\\s*=>[\\s\\S]*?;',
      ),
      '',
    );
    content = content.replaceAll(
      RegExp('extension \\w+Navigation on BuildContext \\{\\s*\\}'),
      '',
    );
    return content;
  }
}
