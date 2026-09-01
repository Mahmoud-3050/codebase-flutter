import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class CubitTestRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import 'package:bloc_test/bloc_test.dart';");
    buffer.writeln("import 'package:either/either.dart';");
    buffer.writeln("import 'package:flutter_test/flutter_test.dart';");
    buffer.writeln("import 'package:mockito/annotations.dart';");
    buffer.writeln("import 'package:mockito/mockito.dart';");
    buffer.writeln();
    buffer.writeln("import 'package:base/core/error/failures.dart';");
    buffer.writeln(
      "import 'package:base/features/$featureNameSnakeCase/data/models/${requestNameSnakeCase}_model.dart';",
    );
    buffer.writeln(
      "import 'package:base/features/$featureNameSnakeCase/domain/usecases/${requestNameSnakeCase}_usecase.dart';",
    );
    buffer.writeln(
      "import 'package:base/features/$featureNameSnakeCase/presentation/controller/$requestNameSnakeCase/${requestNameSnakeCase}_cubit.dart';",
    );
    buffer.writeln();
    buffer.writeln("import '${requestNameSnakeCase}_cubit_test.mocks.dart';");
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final StringBuffer buffer = StringBuffer();
    String responseClassName = request.names.classCase;
    bool hasParams = request.params != null;
    DartType? dataType = request.dartType;

    ///--> @GenerateMocks annotation
    buffer.writeln('@GenerateMocks([${responseClassName}UseCase])');
    buffer.writeln('void main() {');
    buffer.writeln('  late ${responseClassName}Cubit cubit;');
    buffer.writeln('  late Mock${responseClassName}UseCase mockUseCase;');
    buffer.writeln();

    ///--> setUp
    buffer.writeln('  setUp(() {');
    buffer.writeln('    mockUseCase = Mock${responseClassName}UseCase();');
    buffer.writeln('    cubit = ${responseClassName}Cubit(mockUseCase);');
    buffer.writeln('  });');
    buffer.writeln();

    ///--> tearDown
    buffer.writeln('  tearDown(() {');
    buffer.writeln('    cubit.close();');
    buffer.writeln('  });');
    buffer.writeln();

    ///--> Initial state test
    buffer.writeln(
      "  test('initial state is ${responseClassName}InitialState', () {",
    );
    buffer.writeln(
      '    expect(cubit.state, const ${responseClassName}InitialState());',
    );
    buffer.writeln('  });');
    buffer.writeln();

    ///--> Success blocTest
    buffer.writeln("  group('f$responseClassName', () {");

    if (hasParams) {
      ///--> Generate test params
      buffer.writeln('    final tParams = ${responseClassName}Params(');
      request.params?.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        String dartType = getDartType(value);
        String defaultValue = _getDefaultValue(dartType);
        buffer.writeln('      ${keyNames.camelCase}: $defaultValue,');
      });
      buffer.writeln('    );');
      buffer.writeln();
    }

    String dataJson = 'null';
    if (dataType != null) {
      dataJson = dataType.isList
          ? '[]'
          : (dataType == DartType.model ? '<String, dynamic>{}' : "''");
    }

    buffer.writeln(
      '    final tModel = ${responseClassName}Model.fromJson(const <String, dynamic>{',
    );
    buffer.writeln("      'status': 'success',");
    buffer.writeln("      'message': 'Success',");
    if (dataType != null) {
      buffer.writeln("      'data': $dataJson,");
    }
    buffer.writeln('    });');
    buffer.writeln('    final tResponse = tModel;');
    buffer.writeln();

    ///--> Success test
    buffer.writeln(
      '    blocTest<${responseClassName}Cubit, ${responseClassName}State>(',
    );
    buffer.writeln("      'emits [Loading, Success] when usecase succeeds',");
    buffer.writeln('      build: () {');
    buffer.writeln(
      '        when(mockUseCase(any)).thenAnswer((_) async => Right(tResponse));',
    );
    buffer.writeln('        return cubit;');
    buffer.writeln('      },');
    buffer.writeln('      act: (cubit) => cubit.f$responseClassName(');
    if (hasParams) {
      request.params?.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        String dartType = getDartType(value);
        String fallback = _getFallbackValue(dartType);
        buffer.writeln(
          '        ${keyNames.camelCase}: tParams.${keyNames.camelCase} $fallback,',
        );
      });
    }
    buffer.writeln('      ),');
    buffer.writeln('      expect: () => [');
    buffer.writeln('        const ${responseClassName}LoadingState(),');
    if (dataType != null) {
      buffer.writeln(
        '        ${responseClassName}SuccessState(data: tModel.data),',
      );
    } else {
      buffer.writeln('        const ${responseClassName}SuccessState(),');
    }
    buffer.writeln('      ],');
    buffer.writeln('    );');
    buffer.writeln();

    ///--> Error test
    buffer.writeln(
      '    blocTest<${responseClassName}Cubit, ${responseClassName}State>(',
    );
    buffer.writeln("      'emits [Loading, Error] when usecase fails',");
    buffer.writeln('      build: () {');
    buffer.writeln(
      "        when(mockUseCase(any)).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));",
    );
    buffer.writeln('        return cubit;');
    buffer.writeln('      },');
    buffer.writeln('      act: (cubit) => cubit.f$responseClassName(');
    if (hasParams) {
      request.params?.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        String dartType = getDartType(value);
        String fallback = _getFallbackValue(dartType);
        buffer.writeln(
          '        ${keyNames.camelCase}: tParams.${keyNames.camelCase} $fallback,',
        );
      });
    }
    buffer.writeln('      ),');
    buffer.writeln('      expect: () => [');
    buffer.writeln('        const ${responseClassName}LoadingState(),');
    buffer.writeln(
      "        const ${responseClassName}ErrorState(message: 'Server error'),",
    );
    buffer.writeln('      ],');
    buffer.writeln('    );');

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

  String _getFallbackValue(String dartType) {
    switch (dartType) {
      case 'int':
        return '?? 0';
      case 'double':
        return '?? 0.0';
      case 'String':
        return "?? ''";
      case 'bool':
        return '?? false';
      default:
        return '!';
    }
  }
}
