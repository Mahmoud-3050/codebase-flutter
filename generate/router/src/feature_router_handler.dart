// ignore_for_file: avoid_print
import 'dart:io';

import '../../features/models/names.dart';
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
    Map<String, dynamic> args, {
    List<String> scopes = const [],
  }) async {
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
          "import 'package:flutter/material.dart';\n"
          "import 'package:go_router/go_router.dart';\n"
          "import '../../../../config/routes/app_routes.dart';\n"
          '\n'
          "part 'router.g.dart';\n"
          '\n';
    }

    final List<String> registers = registrationNames(feature, scopes);
    if (content.contains('class $routeClass') &&
        content.contains('name: AppRoutes.$screenCamel') &&
        RouterUtils.argsMatch(content, routeClass, args) &&
        RouterUtils.scopesMatch(content, routeClass, registers)) {
      return false;
    }

    final String screenBase = screenBaseName(screenClass);

    if (content.contains('class $routeClass')) {
      content = RouterUtils.removeBlock(content, 'class $routeClass');
    }
    content = RouterUtils.removeBlock(
      content,
      'extension ${screenBase}Navigation',
    );
    content = RouterUtils.removeScopeConstant(content, screenBase);
    content = RouterUtils.stripNavigationMethods(content, screenBase);

    content = RouterUtils.ensureImport(
      content,
      "import '../pages/$screenSnake.dart';",
    );
    if (scopes.isNotEmpty) {
      content = RouterUtils.ensureImport(
        content,
        "import 'package:flutter_bloc/flutter_bloc.dart';",
      );
      content = RouterUtils.ensureImport(
        content,
        "import '../../../../core/di/feature_scope.dart';",
      );
      content = RouterUtils.ensureImport(
        content,
        "import '../../../../injection_container.dart';",
      );
      content = RouterUtils.ensureImport(
        content,
        "import '../../${feature}_injection.dart';",
      );
      for (final String scope in scopes) {
        final String snake = Names.fromString(scope).snakeCase;
        content = RouterUtils.ensureImport(
          content,
          "import '../controller/$snake/${snake}_cubit.dart';",
        );
      }
    }

    final StringBuffer section = StringBuffer();
    if (scopes.isNotEmpty) {
      section.writeln(scopeConstantDeclaration(screenClass));
      section.writeln();
    }
    section.write(
      buildRouteClass(
        routeClass,
        screenClass,
        screenCamel,
        args,
        feature: feature,
        scopes: scopes,
      ),
    );
    section.writeln();
    section.write(buildNavigationExtension(routeClass, screenClass, args));

    content = '${content.trimRight()}\n\n${section.toString()}';
    content = RouterUtils.pruneRouterImports(content, feature);
    content = content.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    await routerFile.writeAsString(content);
    print(
      '${GenerateConstants.greenColorCode}Updated $routerFilePath${GenerateConstants.resetColorCode}',
    );
    return true;
  }

  static String screenBaseName(String screenClass) {
    return screenClass.replaceAll('Screen', '').replaceAll('Page', '');
  }

  static String scopeConstantDeclaration(String screenClass) {
    final Names names = Names.fromString(screenBaseName(screenClass));
    return "const String _${names.camelCase}ScopeName = '${names.classCase}Scope';";
  }

  static String scopeConstantName(String screenClass) {
    final Names names = Names.fromString(screenBaseName(screenClass));
    return '_${names.camelCase}ScopeName';
  }

  static List<String> registrationNames(String feature, List<String> scopes) {
    if (scopes.isEmpty) return const [];
    return <String>[
      'register${Names.fromString(feature).classCase}DataLayer',
      ...scopes.map(
        (String scope) => 'register${Names.fromString(scope).classCase}',
      ),
    ];
  }

  static String buildRouteClass(
    String routeClass,
    String screenClass,
    String screenCamel,
    Map<String, dynamic> args, {
    String feature = '',
    List<String> scopes = const [],
  }) {
    final StringBuffer classBuffer = StringBuffer();
    classBuffer.writeln('@TypedGoRoute<$routeClass>(');
    classBuffer.writeln('  path: AppRoutes.$screenCamel,');
    classBuffer.writeln('  name: AppRoutes.$screenCamel,');
    classBuffer.writeln(')');
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
    if (scopes.isEmpty) {
      classBuffer.writeln(
        '  Widget build(BuildContext context, GoRouterState state) =>',
      );
      classBuffer.writeln(
        '      ${_screenWidgetExpression(screenClass, args)};',
      );
    } else {
      classBuffer.writeln(
        '  Widget build(BuildContext context, GoRouterState state) {',
      );
      classBuffer.write(
        _buildFeatureScopeBody(screenClass, feature, scopes, args),
      );
      classBuffer.writeln('  }');
    }
    classBuffer.writeln('}');
    return classBuffer.toString();
  }

  static String _buildFeatureScopeBody(
    String screenClass,
    String feature,
    List<String> scopes,
    Map<String, dynamic> args,
  ) {
    final List<String> registers = registrationNames(feature, scopes);
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('    return FeatureScope(');
    buffer.writeln('      scopeName: ${scopeConstantName(screenClass)},');
    buffer.writeln('      registrations: const [');
    for (final String register in registers) {
      buffer.writeln('        $register,');
    }
    buffer.writeln('      ],');
    buffer.writeln('      child: MultiBlocProvider(');
    buffer.writeln('        providers: [');
    for (final String scope in scopes) {
      final String cubit = '${Names.fromString(scope).classCase}Cubit';
      buffer.writeln('          BlocProvider(');
      buffer.writeln(
        '            create: (_) => ServiceLocator.instance<$cubit>(),',
      );
      buffer.writeln('          ),');
    }
    buffer.writeln('        ],');
    buffer.writeln(
      '        child: ${_screenWidgetExpression(screenClass, args)},',
    );
    buffer.writeln('      ),');
    buffer.writeln('    );');
    return buffer.toString();
  }

  static String _screenWidgetExpression(
    String screenClass,
    Map<String, dynamic> args,
  ) {
    if (args.isEmpty) return 'const $screenClass()';
    final String params = args.keys
        .map((String key) {
          final String argName = NamesHelper.snakeToCamelCase(
            NamesHelper.toSnakeCase(key),
          );
          return '$argName: $argName';
        })
        .join(', ');
    return '$screenClass($params)';
  }

  static String buildNavigationExtension(
    String routeClass,
    String screenClass,
    Map<String, dynamic> args,
  ) {
    final String screenBase = screenBaseName(screenClass);
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('extension ${screenBase}Navigation on BuildContext {');
    buffer.write(buildNavigationMethod(routeClass, screenClass, args));
    buffer.writeln('}');
    return buffer.toString();
  }

  static String buildNavigationMethod(
    String routeClass,
    String screenClass,
    Map<String, dynamic> args,
  ) {
    final String screenBase = screenBaseName(screenClass);
    final StringBuffer methodBuffer = StringBuffer();

    if (args.isEmpty) {
      methodBuffer.writeln(
        '  void go$screenBase() => const $routeClass().go(this);',
      );
      methodBuffer.writeln();
      methodBuffer.writeln(
        '  Future<T?> push$screenBase<T>() => const $routeClass().push<T>(this);',
      );
    } else {
      methodBuffer.write(
        _buildArgNavigationMethod(
          verb: 'go',
          returnType: 'void',
          methodName: 'go$screenBase',
          routeClass: routeClass,
          args: args,
        ),
      );
      methodBuffer.writeln();
      methodBuffer.write(
        _buildArgNavigationMethod(
          verb: 'push<T>',
          returnType: 'Future<T?>',
          methodName: 'push$screenBase<T>',
          routeClass: routeClass,
          args: args,
        ),
      );
    }
    return methodBuffer.toString();
  }

  static String _buildArgNavigationMethod({
    required String verb,
    required String returnType,
    required String methodName,
    required String routeClass,
    required Map<String, dynamic> args,
  }) {
    final StringBuffer methodBuffer = StringBuffer();
    methodBuffer.writeln('  $returnType $methodName({');
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
          .map((String key) {
            final String argName = NamesHelper.snakeToCamelCase(
              NamesHelper.toSnakeCase(key),
            );
            return '    $argName: $argName,';
          })
          .join('\n'),
    );
    methodBuffer.writeln('  ).$verb(this);');
    return methodBuffer.toString();
  }
}
