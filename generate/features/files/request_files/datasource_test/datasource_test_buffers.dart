import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';


class DatasourceTestRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:mockito/annotations.dart';");
    buffer.writeln("import 'package:mockito/mockito.dart';");
    buffer.writeln();
    buffer.writeln("import 'package:base/injection_container.dart';");
    buffer.writeln("import 'package:base/core/api/dio_consumer.dart';");
    buffer.writeln("import 'package:base/core/error/exceptions.dart';");
    if (hasParams) {
      buffer.writeln("import 'package:base/features/$featureNameSnakeCase/domain/usecases/${requestNameSnakeCase}_usecase.dart';");
    }
    buffer.writeln("import 'package:base/features/$featureNameSnakeCase/data/datasources/${featureNameSnakeCase}_remote_datasource.dart';");
    buffer.writeln("import 'package:base/features/$featureNameSnakeCase/data/models/${requestNameSnakeCase}_model.dart';");
    buffer.writeln();
    buffer.writeln("import '${requestNameSnakeCase}_datasource_test.mocks.dart';");
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    String featureClassName = featureNames.classCase;
    bool hasParams = request.params != null;
    String httpMethod = request.type.name.toLowerCase();
    DartType? dataType = request.dartType;

    buffer.writeln('@GenerateMocks([DioConsumer])');
    buffer.writeln('void main() {');
    buffer.writeln('  late ${featureClassName}RemoteDataSourceImpl dataSource;');
    buffer.writeln('  late MockDioConsumer mockDioConsumer;');
    buffer.writeln();
    buffer.writeln('  setUp(() {');
    buffer.writeln('    mockDioConsumer = MockDioConsumer();');
    buffer.writeln('    ServiceLocator.instance.allowReassignment = true;');
    buffer.writeln('    ServiceLocator.instance.registerSingleton<DioConsumer>(mockDioConsumer);');
    buffer.writeln('    dataSource = ${featureClassName}RemoteDataSourceImpl();');
    buffer.writeln('  });');
    buffer.writeln();

    if (hasParams) {
      buffer.writeln('  final tParams = ${responseClassName}Params(');
      request.params?.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        String dartType = getDartType(value);
        String defaultValue = _getDefaultValue(dartType);
        buffer.writeln('    ${keyNames.camelCase}: $defaultValue,');
      });
      buffer.writeln('  );');
      buffer.writeln();
    }

    String dataJson = 'null';
    if (dataType != null) {
      dataJson = dataType.isList ? '[]' : (dataType == DartType.model ? '<String, dynamic>{}' : "''");
    }

    buffer.writeln('  final tJsonResponse = <String, dynamic>{');
    buffer.writeln("    'status': 'success',");
    buffer.writeln("    'message': 'Success',");
    if (dataType != null) {
      buffer.writeln("    'data': $dataJson,");
    }
    buffer.writeln('  };');
    buffer.writeln();

    buffer.writeln("  group('${request.names.camelCase}', () {");
    buffer.writeln("    test('should perform $httpMethod request and return ${responseClassName}Model when response status is success', () async {");
    buffer.writeln("      when(mockDioConsumer.$httpMethod(any, body: anyNamed('body'), queryParameters: anyNamed('queryParameters')))");
    buffer.writeln('          .thenAnswer((_) async => tJsonResponse);');
    buffer.writeln();
    if (hasParams) {
      buffer.writeln('      final result = await dataSource.${request.names.camelCase}(params: tParams);');
    } else {
      buffer.writeln('      final result = await dataSource.${request.names.camelCase}();');
    }
    buffer.writeln();
    buffer.writeln('      expect(result, isA<${responseClassName}Model>());');
    buffer.writeln('    });');
    buffer.writeln();

    buffer.writeln("    test('should throw ServerException when response status is failure', () async {");
    buffer.writeln('      when(mockDioConsumer.$httpMethod(any, body: anyNamed(\'body\'), queryParameters: anyNamed(\'queryParameters\')))');
    buffer.writeln("          .thenAnswer((_) async => {'status': 'error', 'message': 'Failed'});");
    buffer.writeln();
    if (hasParams) {
      buffer.writeln('      final call = dataSource.${request.names.camelCase};');
      buffer.writeln('      expect(() => call(params: tParams), throwsA(isA<ServerException>()));');
    } else {
      buffer.writeln('      final call = dataSource.${request.names.camelCase};');
      buffer.writeln('      expect(() => call(), throwsA(isA<ServerException>()));');
    }
    buffer.writeln('    });');
    buffer.writeln('  });');
    buffer.writeln('}');

    return buffer;
  }

  String _getDefaultValue(String dartType) {
    switch (dartType) {
      case 'int':
        return '0';
      case 'double':
        return '0.0';
      case 'String':
        return "''";
      case 'bool':
        return 'false';
      default:
        return 'null';
    }
  }
}
