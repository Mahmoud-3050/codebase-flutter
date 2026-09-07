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
    if (request.isPaginatedList) {
      return _generatePaginationBody(request: request);
    }

    String responseClassName = request.names.classCase;
    bool hasParams = request.hasRequestParams;
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
      buffer.writeln('    final tParams = ${responseClassName}Params(');
      request.writeParamsConstructorArgs(buffer: buffer, indent: '      ');
      buffer.writeln('    );');
      buffer.writeln();
    }

    String dataJson = 'null';
    if (dataType != null) {
      dataJson = dataType.isList
          ? '[]'
          : (dataType == .model ? '<String, dynamic>{}' : "''");
    }

    buffer.writeln(
      '    final tModel = ${responseClassName}Model.fromJson(const <String, dynamic>{',
    );
    buffer.writeln("      'status': 'success',");
    buffer.writeln("      'message': 'Success',");
    if (dataType != null) {
      buffer.writeln("      'data': $dataJson,");
    }
    request.writePaginationTestJson(buffer: buffer, indent: '      ');
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
      request.effectiveParams.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        if (request.isPagingParam(key)) {
          buffer.writeln(
            '        ${keyNames.camelCase}: tParams.${keyNames.camelCase},',
          );
          return;
        }
        String dartType = request.dartTypeForParam(key, value);
        String fallback = fallbackValueForDartType(dartType);
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
      request.effectiveParams.forEach((String key, dynamic value) {
        final Names keyNames = Names.fromString(key);
        if (request.isPagingParam(key)) {
          buffer.writeln(
            '        ${keyNames.camelCase}: tParams.${keyNames.camelCase},',
          );
          return;
        }
        String dartType = request.dartTypeForParam(key, value);
        String fallback = fallbackValueForDartType(dartType);
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

  StringBuffer _generatePaginationBody({required Request request}) {
    final StringBuffer buffer = StringBuffer();
    final String responseClassName = request.names.classCase;
    final DartType? dataType = request.dartType;

    buffer.writeln('@GenerateMocks([${responseClassName}UseCase])');
    buffer.writeln('void main() {');
    buffer.writeln('  late ${responseClassName}Cubit cubit;');
    buffer.writeln('  late Mock${responseClassName}UseCase mockUseCase;');
    buffer.writeln();
    buffer.writeln('  setUp(() {');
    buffer.writeln('    mockUseCase = Mock${responseClassName}UseCase();');
    buffer.writeln('    cubit = ${responseClassName}Cubit(mockUseCase);');
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln('  tearDown(() {');
    buffer.writeln('    cubit.close();');
    buffer.writeln('  });');
    buffer.writeln();

    String dataJson = '[]';
    if (dataType != null && dataType != .listModel && !dataType.isList) {
      dataJson = dataType == .model ? '<String, dynamic>{}' : "''";
    }

    buffer.writeln(
      '  final tModel = ${responseClassName}Model.fromJson(const <String, dynamic>{',
    );
    buffer.writeln("    'status': 'success',");
    buffer.writeln("    'message': 'Success',");
    buffer.writeln("    'data': $dataJson,");
    request.writePaginationTestJson(buffer: buffer, indent: '    ');
    buffer.writeln('  });');
    buffer.writeln();

    buffer.writeln(
      "  test('fetchPage maps response data and pagination', () async {",
    );
    buffer.writeln(
      '    when(mockUseCase(any)).thenAnswer((_) async => Right(tModel));',
    );
    buffer.writeln(
      '    final result = await cubit.fetchPage(page: 1, perPage: 10, cancellation: CancelToken());',
    );
    buffer.writeln('    expect(result.isRight, isTrue);');
    buffer.writeln('    expect(result.rightOrNull?.items, tModel.data);');
    buffer.writeln('    expect(result.rightOrNull?.meta, tModel.pagination);');
    buffer.writeln('  });');
    buffer.writeln();

    buffer.writeln("  test('fetchPage forwards a failure', () async {");
    buffer.writeln(
      "    when(mockUseCase(any)).thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));",
    );
    buffer.writeln(
      '    final result = await cubit.fetchPage(page: 1, perPage: 10, cancellation: CancelToken());',
    );
    buffer.writeln('    expect(result.isLeft, isTrue);');
    buffer.writeln('  });');
    buffer.writeln('}');

    return buffer;
  }
}
