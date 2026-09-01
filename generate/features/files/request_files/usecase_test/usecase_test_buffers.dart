import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class UseCaseTestRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:either/either.dart';");
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:mockito/annotations.dart';");
    buffer.writeln("import 'package:mockito/mockito.dart';");
    buffer.writeln();
    if (!hasParams) {
      buffer.writeln("import 'package:base/core/usecases/usecase.dart';");
    }
    buffer.writeln(
      "import 'package:base/features/$featureNameSnakeCase/domain/repositories/${featureNameSnakeCase}_repo.dart';",
    );
    buffer.writeln(
      "import 'package:base/features/$featureNameSnakeCase/domain/usecases/${requestNameSnakeCase}_usecase.dart';",
    );
    buffer.writeln(
      "import 'package:base/features/$featureNameSnakeCase/data/models/${requestNameSnakeCase}_model.dart';",
    );
    buffer.writeln();
    buffer.writeln("import '${requestNameSnakeCase}_usecase_test.mocks.dart';");
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
    DartType? dataType = request.dartType;

    buffer.writeln('@GenerateMocks([${featureClassName}Repository])');
    buffer.writeln('void main() {');
    buffer.writeln('  late ${responseClassName}UseCase useCase;');
    buffer.writeln('  late Mock${featureClassName}Repository mockRepository;');
    buffer.writeln();
    buffer.writeln('  setUp(() {');
    buffer.writeln('    mockRepository = Mock${featureClassName}Repository();');
    buffer.writeln(
      '    useCase = ${responseClassName}UseCase(repository: mockRepository);',
    );
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
      dataJson = dataType.isList
          ? '[]'
          : (dataType == .model ? '<String, dynamic>{}' : "''");
    }

    buffer.writeln(
      '  final tModel = ${responseClassName}Model.fromJson(const <String, dynamic>{',
    );
    buffer.writeln("    'status': 'success',");
    buffer.writeln("    'message': 'Success',");
    if (dataType != null) {
      buffer.writeln("    'data': $dataJson,");
    }
    buffer.writeln('  });');
    buffer.writeln('  final tResponse = tModel;');
    buffer.writeln();

    buffer.writeln("  test('should get response from repository', () async {");
    if (hasParams) {
      buffer.writeln(
        '    when(mockRepository.${request.names.camelCase}(params: anyNamed(\'params\')))',
      );
      buffer.writeln('        .thenAnswer((_) async => Right(tResponse));');
      buffer.writeln();
      buffer.writeln('    final result = await useCase(tParams);');
    } else {
      buffer.writeln(
        '    when(mockRepository.${request.names.camelCase}(params: anyNamed(\'params\')))',
      );
      buffer.writeln('        .thenAnswer((_) async => Right(tResponse));');
      buffer.writeln();
      buffer.writeln('    final result = await useCase(NoParams());');
    }
    buffer.writeln();
    buffer.writeln('    expect(result, Right(tResponse));');
    if (hasParams) {
      buffer.writeln(
        '    verify(mockRepository.${request.names.camelCase}(params: tParams));',
      );
    } else {
      buffer.writeln(
        '    verify(mockRepository.${request.names.camelCase}(params: NoParams()));',
      );
    }
    buffer.writeln('    verifyNoMoreInteractions(mockRepository);');
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
