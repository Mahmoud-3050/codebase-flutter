import '../../../../utils/enums.dart';
import '../../../../utils/functions.dart';
import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';


class RepositoryTestRequestBuffers extends BaseRequestBuffers {
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
    buffer.writeln("import 'package:base/core/error/exceptions.dart';");
    buffer.writeln("import 'package:base/core/error/failures.dart';");
    if (!hasParams) {
      buffer.writeln("import 'package:base/core/usecases/usecase.dart';");
    } else {
      buffer.writeln("import 'package:base/features/$featureNameSnakeCase/domain/usecases/${requestNameSnakeCase}_usecase.dart';");
    }
    buffer.writeln("import 'package:base/features/$featureNameSnakeCase/data/datasources/${featureNameSnakeCase}_remote_datasource.dart';");
    buffer.writeln("import 'package:base/features/$featureNameSnakeCase/data/repositories/${featureNameSnakeCase}_repo_impl.dart';");
    buffer.writeln("import 'package:base/features/$featureNameSnakeCase/data/models/${requestNameSnakeCase}_model.dart';");
    buffer.writeln();
    buffer.writeln("import '${requestNameSnakeCase}_repository_test.mocks.dart';");
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

    buffer.writeln('@GenerateMocks([${featureClassName}RemoteDataSource])');
    buffer.writeln('void main() {');
    buffer.writeln('  late ${featureClassName}RepositoryImpl repository;');
    buffer.writeln('  late Mock${featureClassName}RemoteDataSource mockRemoteDataSource;');
    buffer.writeln();
    buffer.writeln('  setUp(() {');
    buffer.writeln('    mockRemoteDataSource = Mock${featureClassName}RemoteDataSource();');
    buffer.writeln('    repository = ${featureClassName}RepositoryImpl(remote: mockRemoteDataSource);');
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

    buffer.writeln('  final tModel = ${responseClassName}Model.fromJson(const <String, dynamic>{');
    buffer.writeln("    'status': 'success',");
    buffer.writeln("    'message': 'Success',");
    if (dataType != null) {
      buffer.writeln("    'data': $dataJson,");
    }
    buffer.writeln('  });');
    buffer.writeln();

    buffer.writeln("  group('${request.names.camelCase}', () {");
    buffer.writeln("    test('should return remote data when call to remote data source is successful', () async {");
    if (hasParams) {
      buffer.writeln('      when(mockRemoteDataSource.${request.names.camelCase}(params: anyNamed(\'params\')))');
      buffer.writeln('          .thenAnswer((_) async => tModel);');
      buffer.writeln();
      buffer.writeln('      final result = await repository.${request.names.camelCase}(params: tParams);');
    } else {
      buffer.writeln('      when(mockRemoteDataSource.${request.names.camelCase}())');
      buffer.writeln('          .thenAnswer((_) async => tModel);');
      buffer.writeln();
      buffer.writeln('      final result = await repository.${request.names.camelCase}(params: NoParams());');
    }
    buffer.writeln();
    buffer.writeln('      expect(result, Right(tModel));');
    if (hasParams) {
      buffer.writeln('      verify(mockRemoteDataSource.${request.names.camelCase}(params: tParams));');
    } else {
      buffer.writeln('      verify(mockRemoteDataSource.${request.names.camelCase}());');
    }
    buffer.writeln('      verifyNoMoreInteractions(mockRemoteDataSource);');
    buffer.writeln('    });');
    buffer.writeln();

    buffer.writeln("    test('should return ServerFailure when call to remote data source throws ServerException', () async {");
    if (hasParams) {
      buffer.writeln('      when(mockRemoteDataSource.${request.names.camelCase}(params: anyNamed(\'params\')))');
      buffer.writeln("          .thenThrow(const ServerException(message: 'Server error'));");
      buffer.writeln();
      buffer.writeln('      final result = await repository.${request.names.camelCase}(params: tParams);');
    } else {
      buffer.writeln('      when(mockRemoteDataSource.${request.names.camelCase}())');
      buffer.writeln("          .thenThrow(const ServerException(message: 'Server error'));");
      buffer.writeln();
      buffer.writeln('      final result = await repository.${request.names.camelCase}(params: NoParams());');
    }
    buffer.writeln();
    buffer.writeln("      expect(result, const Left(ServerFailure(message: 'Server error')));");
    if (hasParams) {
      buffer.writeln('      verify(mockRemoteDataSource.${request.names.camelCase}(params: tParams));');
    } else {
      buffer.writeln('      verify(mockRemoteDataSource.${request.names.camelCase}());');
    }
    buffer.writeln('      verifyNoMoreInteractions(mockRemoteDataSource);');
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
