import 'dart:io';

import '../../utils/constants.dart';
import '../../utils/names_helper.dart';
import '../../utils/functions.dart';
import 'router_utils.dart';

class FeatureRouterHandler {
  static Future<bool> updateFeatureRouter(
    String feature,
    String screenClass,
    String screenSnake,
    String screenCamel,
    String routeClass,
    Map<String, dynamic> args,
  ) async {
    final String navPath = 'lib/features/$feature/presentation/navigation';
    final String routerFilePath = '$navPath/router.dart';
    final File routerFile = File(routerFilePath);

    if (!Directory(navPath).existsSync()) {
      Directory(navPath).createSync(recursive: true);
    }

    String content = '';
    if (routerFile.existsSync()) {
      content = await routerFile.readAsString();
    } else {
      content =
          "import 'package:flutter/material.dart';\nimport 'package:go_router/go_router.dart';\nimport '../../../../config/routes/app_routes.dart';\n\npart 'router.g.dart';\n\n";
    }

    if (content.contains('class $routeClass') &&
        content.contains('name: AppRoutes.$screenCamel') &&
        RouterUtils.argsMatch(content, routeClass, args)) {
      return false;
    }

    if (content.contains('class $routeClass')) {
      content = RouterUtils.removeBlock(content, 'class $routeClass');
      final String screenBase = screenClass
          .replaceAll('Screen', '')
          .replaceAll('Page', '');

      // Remove old navigation methods (to, go, push)
      content = content.replaceAll(
        RegExp(
          'void (to|go|push)$screenBase\\s*\\(.*?\\)\\s*(=>|{).*?;',
          dotAll: true,
        ),
        '',
      );
    }

    final String screenImport = "import '../pages/$screenSnake.dart';";
    if (!content.contains(screenImport)) {
      int lastImport = content.lastIndexOf('import ');
      if (lastImport != -1) {
        int endOfLine = content.indexOf('\n', lastImport);
        content =
            '${content.substring(0, endOfLine + 1)}$screenImport\n${content.substring(endOfLine + 1)}';
      } else {
        content = '$screenImport\n\n$content';
      }
    }

    final String routeData = buildRouteClass(
      routeClass,
      screenClass,
      screenCamel,
      args,
    );
    final String navMethod = buildNavigationMethod(
      routeClass,
      screenClass,
      args,
    );

    final String extName =
        '${feature.substring(0, 1).toUpperCase()}${feature.substring(1)}Navigation';
    final String extHeader = 'extension $extName on BuildContext {';

    if (!content.contains(extHeader)) {
      content += routeData;
      content += '\n\n$extHeader$navMethod}\n';
    } else {
      int extIndex = content.indexOf(extHeader);
      String head = content.substring(0, extIndex);
      String tail = content.substring(extIndex);
      int lastBrace = tail.lastIndexOf('}');
      content =
          '$head$routeData\n${tail.substring(0, lastBrace)}$navMethod${tail.substring(lastBrace)}';
    }

    await routerFile.writeAsString(content);
    print(
      '${GenerateConstants.greenColorCode}Updated $routerFilePath${GenerateConstants.resetColorCode}',
    );
    return true;
  }

  static String buildRouteClass(
    String routeClass,
    String screenClass,
    String screenCamel,
    Map<String, dynamic> args,
  ) {
    final StringBuffer classBuffer = StringBuffer();
    classBuffer.writeln(
      '\n@TypedGoRoute<$routeClass>(path: AppRoutes.$screenCamel, name: AppRoutes.$screenCamel)',
    );
    classBuffer.writeln(
      'class $routeClass extends GoRouteData with \$$routeClass {',
    );
    for (var entry in args.entries) {
      final String argName = NamesHelper.snakeToCamelCase(
        NamesHelper.toSnakeCase(entry.key),
      );
      classBuffer.writeln('  final ${getDartType(entry.value)} $argName;');
    }
    classBuffer.writeln();
    if (args.isEmpty) {
      classBuffer.writeln('  const $routeClass();');
    } else {
      classBuffer.writeln('  const $routeClass({');
      for (var key in args.keys) {
        final String argName = NamesHelper.snakeToCamelCase(
          NamesHelper.toSnakeCase(key),
        );
        classBuffer.writeln('    required this.$argName,');
      }
      classBuffer.writeln('  });');
    }
    classBuffer.writeln();
    classBuffer.writeln('  @override');
    if (args.isEmpty) {
      classBuffer.writeln(
        '  Widget build(BuildContext context, GoRouterState state) => const $screenClass();',
      );
    } else {
      classBuffer.write(
        '  Widget build(BuildContext context, GoRouterState state) => $screenClass(',
      );
      classBuffer.write(
        args.keys
            .map((k) {
              final String argName = NamesHelper.snakeToCamelCase(
                NamesHelper.toSnakeCase(k),
              );
              return '$argName: $argName';
            })
            .join(', '),
      );
      classBuffer.writeln(');');
    }
    classBuffer.writeln('}');
    return classBuffer.toString();
  }

  static String buildNavigationMethod(
    String routeClass,
    String screenClass,
    Map<String, dynamic> args,
  ) {
    final String screenBase = screenClass
        .replaceAll('Screen', '')
        .replaceAll('Page', '');
    final StringBuffer methodBuffer = StringBuffer();

    // Generate .go() and .push() variants
    for (var verb in ['go', 'push']) {
      final String methodName = '$verb$screenBase';
      if (args.isEmpty) {
        methodBuffer.writeln(
          '  void $methodName() => const $routeClass().$verb(this);',
        );
      } else {
        methodBuffer.writeln('  void $methodName({');
        for (var entry in args.entries) {
          final String argName = NamesHelper.snakeToCamelCase(
            NamesHelper.toSnakeCase(entry.key),
          );
          methodBuffer.writeln(
            '    required ${getDartType(entry.value)} $argName,',
          );
        }
        methodBuffer.writeln('  }) => $routeClass(');
        methodBuffer.writeln(
          args.keys
              .map((k) {
                final String argName = NamesHelper.snakeToCamelCase(
                  NamesHelper.toSnakeCase(k),
                );
                return '    $argName: $argName,';
              })
              .join('\n'),
        );
        methodBuffer.writeln('  ).$verb(this);');
      }
    }
    return methodBuffer.toString();
  }
}
