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
    int startIndex = content.indexOf(startPattern);
    if (startIndex == -1) return content;

    // Find @TypedGoRoute before it
    int annotIndex = content.lastIndexOf('@TypedGoRoute', startIndex);
    if (annotIndex != -1) startIndex = annotIndex;

    int blockEnd = findBlockEnd(content, startIndex);
    if (blockEnd == -1) return content;

    return content.substring(0, startIndex) + content.substring(blockEnd);
  }

  static bool argsMatch(
      String content, String routeClass, Map<String, dynamic> args) {
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
      final String argName =
          NamesHelper.snakeToCamelCase(NamesHelper.toSnakeCase(key));
      if (!classContent.contains('final ${getDartType(args[key])} $argName;')) {
        return false;
      }
    }

    int fieldCount = 'final '.allMatches(classContent).length;
    return fieldCount == args.length;
  }
}
