import '../../../models/names.dart';
import '../../../models/request.dart';
import '../../request_buffers.dart';

class DatasourceRequestBuffers extends BaseRequestBuffers {
  @override
  StringBuffer generateImports({
    String featureNameSnakeCase = '',
    bool hasParams = false,
    String requestNameSnakeCase = '',
    bool isDataModel = false,
  }) {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln("import '../models/${requestNameSnakeCase}_model.dart';");
    return buffer;
  }

  @override
  StringBuffer generateBody({
    required Names featureNames,
    required Request request,
  }) {
    final bool hasParams = request.params != null;
    final StringBuffer buffer = StringBuffer();

    /// Func
    buffer.writeln(
      '  Future<${request.names.classCase}Model> ${request.names.camelCase}({',
    );
    buffer.writeln('    required Params params,');
    buffer.writeln('  });');
    buffer.writeln();

    /// Separator
    buffer.writeln('***');

    /// Func impl
    buffer.writeln('  @override');
    buffer.writeln(
      '  Future<${request.names.classCase}Model> ${request.names.camelCase}({',
    );
    buffer.writeln('    required Params params,');
    buffer.writeln('  }) async {');
    buffer.writeln('    try {');
    if (request.endpoint.hasParams) {
      buffer.writeln(
        "      String ${request.names.camelCase}Endpoint = '${request.endpoint.endpoint}';",
      );
    } else {
      buffer.writeln(
        "      const String ${request.names.camelCase}Endpoint = '${request.endpoint.endpoint}';",
      );
    }
    buffer.writeln(
      '      final dynamic response = await dioConsumer.${request.type.name.toLowerCase()}(',
    );
    buffer.writeln('        ${request.names.camelCase}Endpoint,');
    final bool isBodyRequest =
        request.type == .post || request.type == .put || request.type == .patch;
    if (hasParams && isBodyRequest) {
      buffer.writeln('        body: params.toJson(),');
    }
    if (hasParams && request.type == .get && request.endpoint.hasQueryParams) {
      buffer.writeln('        queryParameters: params.toJson(),');
    }
    buffer.writeln(
      '        cancelToken: requestCancelToken(params.cancellation),',
    );
    buffer.writeln('      );');
    buffer.writeln();
    buffer.writeln('      if (ApiResponse.isSuccess(response)) {');
    buffer.writeln(
      '        return ${request.names.classCase}Model.fromJson(response);',
    );
    buffer.writeln('      }');
    buffer.writeln(
      '      throw ServerException(message: ApiResponse.messageOf(response));',
    );
    buffer.writeln('    } catch (error) {');
    buffer.writeln('      rethrow;');
    buffer.writeln('    }');
    buffer.writeln('  }');
    buffer.writeln();
    return buffer;
  }
}
